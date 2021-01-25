//
//  UploadOperation.swift
//  Depo
//
//  Created by Konstantin on 4/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MBProgressHUD
import FirebaseCrashlytics

enum ResumableUploadStatus {
    case uploaded(bytes: Int)
    case didntStart
    case invalidUploadRequest
    case discontinuityError
    case completed
}


typealias UploadOperationSuccess = (_ uploadOperation: UploadOperation) -> Void
typealias UploadOperationHandler = (_ uploadOperation: UploadOperation, _ value: ErrorResponse?) -> Void
typealias ResumableUploadHandler = (_ status: ResumableUploadStatus?, _ error: ErrorResponse?) -> Void

final class UploadOperation: Operation {
    
    typealias UploadParametersResponse = (UploadRequestParametrs) -> Void
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var privateShareService = PrivateShareApiServiceImpl()
    
    let inputItem: WrapData
    private(set) var outputItem: WrapData?
    var uploadType: UploadType?
    private let uploadStategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let folder: String
    private let accountUuid: String?
    private var requestObject: URLSessionTask?
    private let handler: UploadOperationHandler?
    private var isFavorites: Bool = false
    private var isPhotoAlbum: Bool = false
    private var attemptsCount = 0
    private let semaphore: DispatchSemaphore
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.uploadOperation)
    private var clearingAction: VoidHandler?
    private var chunker: DataChunkProvider?
    private let resumableInfoService: ResumableUploadInfoService = factory.resolve()
    private let interruptedId: String?
    private let isResumable: Bool
    private var wasInterrupted: Bool = false
    private var fileSize: Int64 {
        if isResumable {
            return Int64(chunker?.fileSize ?? 0)
        } else {
            return inputItem.fileSize
        }
    }
    
    private lazy var storageVars: StorageVars = factory.resolve()
    
    //MARK: - Init
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, projectId: String? = nil, handler: @escaping UploadOperationHandler) {
        self.inputItem = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.accountUuid = projectId
        self.handler = handler
        self.semaphore = DispatchSemaphore(value: 0)
        self.isFavorites = isFavorites
        self.isPhotoAlbum = isFromAlbum
        
//        if uploadType != .sharedWithMe {
//            if item.fileType.isContained(in: [.video]), resumableInfoService.isResumableUploadAllowed(with: item.fileSize.intValue) {
//                self.isResumable = true
//            } else {
//                self.isResumable = false
//            }
//        } else {
            self.isResumable = false
//        }
        
        let trimmedLocalId = self.inputItem.getTrimmedLocalID()
        self.interruptedId = resumableInfoService.getInterruptedId(for: trimmedLocalId)
        
        super.init()
        
        setupQualityOfService(uploadType: uploadType)
    }
    
    private func setupQualityOfService(uploadType: UploadType) {
        switch uploadType {
            case .syncToUse:
            qualityOfService = .userInteractive
        case .upload, .sharedWithMe:
            qualityOfService = .userInitiated
        }
    }
    
    //MARK: - Overriding
    
    override func cancel() {
        super.cancel()
        
        requestObject?.cancel()
        
        handler?(self, ErrorResponse.string(TextConstants.canceledOperationTextError))
        
        semaphore.signal()
    }
    
    override func main() {
        
        BackgroundTaskService.shared.beginBackgroundTask()
        
        ItemOperationManager.default.startUploadFile(file: inputItem)
        
        WidgetService.shared.notifyWidgetAbout(syncFileName: inputItem.name ?? "")
        
        SingletonStorage.shared.progressDelegates.add(self)
        
        attemptUpload()
        
        semaphore.wait()
        
        clearingAction?()
        SingletonStorage.shared.progressDelegates.remove(self)
    }
    
    private func retry(block: @escaping VoidHandler) {
        let delay: DispatchTime = .now() + .seconds(NumericConstants.secondsBeetweenUploadAttempts)
        debugLog("retrying in \(NumericConstants.secondsBeetweenUploadAttempts) second(s)")
        dispatchQueue.asyncAfter(deadline: delay, execute: { [weak self] in
            guard let self = self, self.isExecuting else {
                return
            }
            
            self.attemptsCount += 1
            block()
        })
    }
    

    //MARK: - Resumable

    private func attemptResumableUpload(success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        guard !isCancelled else {
            fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
            return
        }
        
        guard let asset = self.inputItem.asset else {
            fail(ErrorResponse.string(TextConstants.commonServiceError))
            return
        }
        
        LocalMediaStorage.default.getUrlOfCoppiedData(asset: asset) { [weak self] result in
            self?.dispatchQueue.async {
                guard let self = self, !self.isCancelled else {
                    fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                    return
                }
                
                switch result {
                case .success(let localUrl):
                    let bufferCapacity = self.resumableInfoService.chunkSize
                    self.chunker = DataChunkProviderFactory.createWithSource(source: localUrl, bufferCapacity: bufferCapacity)
                    
                    self.requestObject = self.baseUrl(success: { [weak self] baseUrl in
                        guard let self = self, !self.isCancelled else {
                            fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                            return
                        }
                        
                        guard let baseURL = baseUrl else {
                            fail(ErrorResponse.string(TextConstants.commonServiceError))
                            return
                        }
                        
                        self.getUploadParameters(baseURL: baseURL, empty: true, success: { [weak self] parameters in
                            guard let self = self, !self.isCancelled else {
                                fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                                return
                            }
                            
                            guard let resumableParameters = parameters as? ResumableUpload else {
                                fail(ErrorResponse.string(TextConstants.commonServiceError))
                                return
                            }
                            
                            self.clearingAction = { [weak self] in
                                self?.removeTemporaryFile(at: localUrl)
                            }
                            
                            guard self.interruptedId != nil else {
                                self.showToast(message: "Resumable upload")
                                /// can't check resumable status because don't have any related interrupted id
                                self.uploadContiniously(parameters: resumableParameters, success: success, fail: fail)
                                
                                let trimmedId = self.inputItem.getTrimmedLocalID()
                                self.resumableInfoService.save(interruptedId: resumableParameters.tmpUUID, for: trimmedId)
                                return
                            }
                            
                            self.checkResumeStatus(parameters: resumableParameters) { [weak self] status, error in
                                guard let self = self, !self.isCancelled else {
                                    fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                                    return
                                }
                                
                                guard let status = status else {
                                    let error = error ?? ErrorResponse.string(TextConstants.commonServiceError)
                                    fail(error)
                                    return
                                }
                                
                                debugLog("resumable_upload: status is \(status)")
                                
                                switch status {
                                case .completed:
                                    self.finishUploading(parameters: resumableParameters, success: success, fail: fail)
                                    
                                case .didntStart:
                                    self.uploadContiniously(parameters: resumableParameters, success: success, fail: fail)
                                    
                                case .uploaded(bytes: let bytesToSkip):
                                    debugLog("resumable_upload: bytes to skip \(bytesToSkip)")
                                    
                                    if bytesToSkip > 0 {
                                        self.wasInterrupted = true
                                        self.trackResumableUploadWasInterrrupted()
                                    }
                                    
                                    guard let nextChunk = self.chunker?.nextChunk(skipping: bytesToSkip) else {
                                        fail(ErrorResponse.string(TextConstants.commonServiceError))
                                        return
                                    }
                                    
                                    self.uploadContiniously(parameters: resumableParameters, chunk: nextChunk, success: success, fail: fail)
                                    
                                case .discontinuityError, .invalidUploadRequest:
                                    self.retry {
                                        self.attemptResumableUpload(success: success, fail: fail)
                                    }
                                }
                            }
                            
                            }, fail: fail)
                        
                        }, fail: fail)
                    
                case .failed(let error):
                    fail(.error(error))
                }
            }
        }
    }
    
    private func checkResumeStatus(parameters: ResumableUpload, handler: @escaping ResumableUploadHandler) {
        debugLog("resumable_upload: checking status")
        showToast(message: "Resumable status")
        requestObject = resumableUpload(uploadParam: parameters, handler: { [weak self] status, error in
            self?.dispatchQueue.async {
                guard let self = self, !self.isCancelled else {
                    handler(status, ErrorResponse.string(TextConstants.canceledOperationTextError))
                    return
                }
                
                if let error = error, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                    self.retry { [weak self] in
                        self?.checkResumeStatus(parameters: parameters, handler: handler)
                    }
                    return
                }
                
                self.attemptsCount = 0
                handler(status, error)
            }
        })
    }
    
    private func uploadContiniously(parameters: ResumableUpload, chunk: DataChunk? = nil, success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        
        guard let nextChunk = chunk != nil ? chunk : chunker?.nextChunk() else {
            debugLog("resumable_upload: next chunk is unavailable")
            fail(ErrorResponse.string(TextConstants.commonServiceError))
            return
        }
        
        parameters.update(chunk: nextChunk)
        
        debugLog("resumable_upload: chunk range is \(nextChunk.range)")
        
        requestObject = resumableUpload(uploadParam: parameters, handler: { [weak self] status, error in
            self?.dispatchQueue.async {
                guard let self = self, !self.isCancelled else {
                    fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                    return
                }
                
                if let error = error {
                    if error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                        self.retry { [weak self] in
                            self?.uploadContiniously(parameters: parameters, chunk: nextChunk, success: success, fail: fail)
                        }
                    } else {
                        fail(error)
                    }
                    return
                }
                
                guard let status = status else {
                    let error = error ?? ErrorResponse.string(TextConstants.commonServiceError)
                    fail(error)
                    return
                }
                
                debugLog("resumable_upload: status is \(status)")
                
                switch status {
                case .completed:
                    
                    if self.wasInterrupted {
                        self.trackInterractedResumableUploadCompletedSyccessfully()
                    }
                    
                    self.showToast(message: "Resumable upload completed")
                    self.finishUploading(parameters: parameters, success: success, fail: fail)
                    
                case .didntStart:
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    
                case .uploaded(bytes: _):
                    debugLog("resumable_upload: should continue")
                    
                    self.attemptsCount = 0
                    self.uploadContiniously(parameters: parameters, success: success, fail: fail)
                    
                case .discontinuityError, .invalidUploadRequest:
                    self.retry {
                        self.attemptResumableUpload(success: success, fail: fail)
                    }
                }
            }
        })

        ///If upload service can't create upload request task for some reason
        if self.requestObject == nil {
            fail(ErrorResponse.string(TextConstants.commonServiceError))
        }
    }

    
    //MARK: - Simple
    private func attemptSimpleUpload(success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        requestObject = baseUrl(success: { [weak self] baseUrl in
            guard let self = self, !self.isCancelled else {
                fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                return
            }
            
            guard let baseURL = baseUrl else {
                fail(ErrorResponse.string(TextConstants.commonServiceError))
                return
            }
            
            self.getUploadParameters(baseURL: baseURL, success: { [weak self] parameters in
                guard let self = self, !self.isCancelled else {
                    fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                    return
                }
                
                self.clearingAction = { [weak self] in
                    self?.removeTemporaryFile(at: parameters.urlToLocalFile)
                }
                
                self.requestObject = self.upload(uploadParam: parameters, success: { [weak self] in
                    debugLog("simple_upload: uploaded")
                    
                    self?.finishUploading(parameters: parameters, success: success, fail: fail)
                    
                    }, fail: { [weak self] error in
                       guard let self = self, !self.isCancelled else {
                            fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                            return
                        }
                        
                        if error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                            self.retry { [weak self] in
                                self?.attemptSimpleUpload(success: success, fail: fail)
                            }
                        } else {
                            fail(error)
                        }
                })
                
                ///If upload service can't create upload request task for some reason
                if self.requestObject == nil {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                }
            }, fail: fail)
        }, fail: fail)
    }
    
    
    //MARK: - General
    private func attemptUpload() {
        let customSucces: FileOperationSucces = { [weak self] in
            guard let self = self else {
                return
            }
            
            let trimmedId = self.inputItem.getTrimmedLocalID()
            self.resumableInfoService.removeInterruptedId(for: trimmedId)
            
            self.handler?(self, nil)
            self.semaphore.signal()
        }
        
        let customFail: FailResponse = { [weak self] value in
            guard let self = self else {
                return
            }
            
            let errorResponse = self.isCancelled ? ErrorResponse.string(TextConstants.canceledOperationTextError) : value
            
            debugLog("_upload: error is \(errorResponse.description)")
            
            self.handler?(self, errorResponse)
            self.semaphore.signal()
        }
        
        if isResumable {
            debugLog("resumable_upload:")
            attemptResumableUpload(success: customSucces, fail: customFail)
        } else {
            debugLog("simple_upload:")
            attemptSimpleUpload(success: customSucces, fail: customFail)
        }
    }
    
    private func getUploadParameters(baseURL: URL, empty: Bool = false, success: @escaping UploadParametersResponse, fail: @escaping FailResponse) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                fail(ErrorResponse.string(TextConstants.canceledOperationTextError))
                return
            }
            
            let parameters: UploadRequestParametrs

            if self.isResumable {
                parameters = ResumableUpload(item: self.inputItem,
                                             empty: empty,
                                             fileSize: self.chunker?.fileSize,
                                             interruptedUploadId: self.interruptedId,
                                             destitantion: baseURL,
                                             uploadStategy: self.uploadStategy,
                                             uploadTo: self.uploadTo,
                                             rootFolder: self.folder,
                                             isFavorite: self.isFavorites,
                                             uploadType: self.uploadType)
            } else {
                parameters = SimpleUpload.with(item: self.inputItem,
                                               destitantion: baseURL,
                                               uploadStategy: self.uploadStategy,
                                               uploadTo: self.uploadTo,
                                               rootFolder: self.folder,
                                               isFavorite: self.isFavorites,
                                               uploadType: self.uploadType)
            }
            
            success(parameters)
        }
    }
    
    private func finishUploading(parameters: UploadRequestParametrs, success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        
        inputItem.syncStatus = .synced
        inputItem.setSyncStatusesAsSyncedForCurrentUser()
        
        outputItem = inputItem
//        self.outputItem?.tmpDownloadUrl = response.tempDownloadURL
//        self.outputItem?.metaData?.takenDate = self.inputItem.metaDate
//        self.outputItem?.metaData?.duration = self.inputItem.metaData?.duration ?? Double(0.0)
        
        //TODO: remove this in the future
        if let size = (parameters as? SimpleUpload)?.fileSize, let item = self.outputItem, size != item.fileSize {
            Crashlytics.crashlytics().record(error: CustomErrors.text("UPLOAD: finishUploading -> uploadNotify sizes arent equal"))
            debugLog("UPLOAD: finishUploading -> parSize \(size) newRemote size \(item.fileSize) param URL \(parameters.urlToLocalFile?.path ?? "nil")")
        }
        //--
        
        success()
    }
    
    private func removeTemporaryFile(at localURL: URL?) {
        if let localURL = localURL {
            do {
                try FileManager.default.removeItem(at: localURL)
            } catch {
                print(error.description)
            }
        }
    }
    
    //MARK: - Requests
    
    private func baseUrl(success: @escaping ValueHandler<URL?>, fail: FailResponse?) -> URLSessionTask? {
        if let accountUuid = accountUuid {
            let requestItem = UploadFileRequestItem(uuid: inputItem.uuid, name: inputItem.name ?? "", sizeInBytes: fileSize, mimeType: inputItem.uploadContentType)
            
            return privateShareService.getUrlToUpload(projectId: accountUuid, parentFolderUuid: folder, requestItem: requestItem) { [weak self] response in
                switch response {
                    case .success(let wrappedUrl):
                        success(wrappedUrl.url)
                        
                    case .failed(let error):
                        fail?(ErrorResponse.error(error))
                }
            }
            
        } else {
            fail?(ErrorResponse.string(TextConstants.commonServiceError))
            return nil
        }
    }
    
    private func upload(uploadParam: UploadRequestParametrs, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask? {
        return UploadService.default.upload(uploadParam: uploadParam,
                                            success: success,
                                            fail: fail)
    }
    
    private func resumableUpload(uploadParam: ResumableUpload, handler: @escaping ResumableUploadHandler) -> URLSessionTask? {
        return UploadService.default.resumableUpload(uploadParam: uploadParam, handler: handler)
    }
}



//MARK: - OperationProgressServiceDelegate

extension UploadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting else {
            return
        }
        
        let actualRatio: Float
        if isResumable, let chunker = chunker {
            let bytesUploaded = chunker.lastRange.lowerBound + bytes
            actualRatio = Float(bytesUploaded) / Float(chunker.fileSize)
        } else {
            actualRatio = ratio
        }
        
        if requestObject?.currentRequest?.url == url, let uploadType = uploadType {
            CardsManager.default.setProgress(ratio: actualRatio, operationType: UploadService.convertUploadType(uploadType: uploadType), object: inputItem)
            ItemOperationManager.default.setProgressForUploadingFile(file: inputItem, progress: actualRatio)
        }
    }
    
    
    private func showToast(message: String) {
        return
        /// uncomment for test purpose only
//
//        DispatchQueue.toMain {
//
//            guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
//                return
//            }
//
//            let hud = MBProgressHUD.showAdded(to: window, animated: true)
//
//            hud.label.text = message
//            hud.mode = .text
//            hud.removeFromSuperViewOnHide = true
//            hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
//
//            hud.hide(animated: true, afterDelay: 2.0)
//        }
    }
}

extension UploadOperation {
    private func trackResumableUploadWasInterrrupted() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .uploadProcess,
                                            eventLabel: .restart)
    }
    
    private func trackInterractedResumableUploadCompletedSyccessfully() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .uploadProcess,
                                            eventLabel: .success)
    }
}
