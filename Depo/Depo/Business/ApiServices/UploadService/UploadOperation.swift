//
//  UploadOperation.swift
//  Depo
//
//  Created by Konstantin on 4/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MBProgressHUD


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
    
    private let mediaItemsService = MediaItemOperationsService.shared
    private let mediaAlbumsService = MediaItemsAlbumOperationService.shared
    private let remoteAlbumsService = PhotosAlbumService()
    
    let inputItem: WrapData
    private(set) var outputItem: WrapData?
    var uploadType: UploadType?
    private let uploadStategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let folder: String
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
    
    
    //MARK: - Init
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, handler: @escaping UploadOperationHandler) {
        self.inputItem = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.handler = handler
        self.semaphore = DispatchSemaphore(value: 0)
        self.isFavorites = isFavorites
        self.isPhotoAlbum = isFromAlbum
        
        self.isResumable = resumableInfoService.isResumableUploadAllowed(with: item.fileSize.intValue)
        
        let trimmedLocalId = self.inputItem.getTrimmedLocalID()
        self.interruptedId = resumableInfoService.getInterruptedId(for: trimmedLocalId)
        
        super.init()
        
        setupQualityOfService(uploadType: uploadType)
    }
    
    private func setupQualityOfService(uploadType: UploadType) {
        switch uploadType {
        case .syncToUse:
            qualityOfService = .userInteractive
        case .upload:
            qualityOfService = .userInitiated
        case .autoSync:
            qualityOfService = .background
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
        
        SingletonStorage.shared.progressDelegates.add(self)
        
        attemptUpload()
        
        semaphore.wait()
        
        clearingAction?()
        SingletonStorage.shared.progressDelegates.remove(self)
    }
    
    private func retry(block: @escaping VoidHandler) {
        let delay: DispatchTime = .now() + .seconds(NumericConstants.secondsBeetweenUploadAttempts)
        debugLog("retrying in \(NumericConstants.secondsBeetweenUploadAttempts) second(s)")
        dispatchQueue.asyncAfter(deadline: delay, execute: {
            self.attemptsCount += 1
            block()
        })
    }
    

    //MARK: - Resumable

    private func attemptResumableUpload(success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        guard
            let asset = inputItem.asset,
            let localUrl = LocalMediaStorage.default.getURL(asset: asset)
        else {
            fail(ErrorResponse.string(TextConstants.commonServiceError))
            return
        }
        
        let bufferCapacity = resumableInfoService.chunkSize
        self.chunker = DataChunkProviderFactory.createWithSource(source: localUrl, bufferCapacity: bufferCapacity)
        
        requestObject = baseUrl(success: { [weak self] baseurlResponse in
            guard let self = self,
                let baseURL = baseurlResponse?.url else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
            }
            
            self.getUploadParameters(baseURL: baseURL, empty: true, success: { [weak self] parameters in
                guard let self = self, let resumableParameters = parameters as? ResumableUpload else {
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
                    guard let self = self else {
                        fail(ErrorResponse.string(TextConstants.commonServiceError))
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
    }
    
    private func checkResumeStatus(parameters: ResumableUpload, handler: @escaping ResumableUploadHandler) {
        debugLog("resumable_upload: checking status")
        showToast(message: "Resumable status")
        requestObject = resumableUpload(uploadParam: parameters, handler: { [weak self] status, error in
            self?.dispatchQueue.async {
                guard let self = self else {
                    handler(status, ErrorResponse.string(TextConstants.commonServiceError))
                    return
                }
                
                if let error = error, !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                    
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
                guard let self = self else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
                }
                
                if let error = error {
                    if !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
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
        requestObject = baseUrl(success: { [weak self] baseurlResponse in
            guard let self = self,
                let baseURL = baseurlResponse?.url else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
            }
            
            self.getUploadParameters(baseURL: baseURL, success: { [weak self] parameters in
                guard let self = self else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
                }

                self.clearingAction = { [weak self] in
                    self?.removeTemporaryFile(at: parameters.urlToLocalFile)
                }
                
                self.requestObject = self.upload(uploadParam: parameters, success: { [weak self] in
                    debugLog("simple_upload: uploaded")
                    
                    self?.finishUploading(parameters: parameters, success: success, fail: fail)
                    
                    }, fail: { [weak self] error in
                        guard let self = self else {
                            return
                        }
                        
                        if !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
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
        
        createAlbumsIfNeeded { [weak self] in
            guard let self = self else {
                customFail(ErrorResponse.string(TextConstants.errorUnknown))
                return
            }
            
            if self.isResumable {
                debugLog("resumable_upload:")
                self.attemptResumableUpload(success: customSucces, fail: customFail)
            } else {
                debugLog("simple_upload:")
                self.attemptSimpleUpload(success: customSucces, fail: customFail)
            }
        }
        
        
    }
    
    private func getUploadParameters(baseURL: URL, empty: Bool = false, success: @escaping UploadParametersResponse, fail: @escaping FailResponse) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                fail(ErrorResponse.string(TextConstants.errorUnknown))
                return
            }
            
            let parameters: UploadRequestParametrs
            
            if self.isResumable {
                parameters = ResumableUpload(item: self.inputItem,
                                             empty: empty,
                                             interruptedUploadId: self.interruptedId,
                                             destitantion: baseURL,
                                             uploadStategy: self.uploadStategy,
                                             uploadTo: self.uploadTo,
                                             rootFolder: self.folder,
                                             isFavorite: self.isFavorites,
                                             uploadType: self.uploadType)
            } else {
                parameters = SimpleUpload(item: self.inputItem,
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
        let uploadNotifParam = UploadNotify(parentUUID: parameters.rootFolder,
                                            fileUUID: parameters.tmpUUID )
        
        inputItem.syncStatus = .synced
        inputItem.setSyncStatusesAsSyncedForCurrentUser()
        
        uploadNotify(param: uploadNotifParam, success: { [weak self] baseurlResponse in
            self?.dispatchQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard let response = baseurlResponse as? SearchItemResponse else {
                    success()
                    return
                }
                
                self.outputItem = WrapData(remote: response)
                self.addPhotoToTheAlbum(with: parameters, response: response)
                self.outputItem?.tmpDownloadUrl = response.tempDownloadURL
                self.outputItem?.metaData?.takenDate = self.inputItem.metaDate
                self.outputItem?.metaData?.duration = self.inputItem.metaData?.duration ?? Double(0.0)
                
                //case for upload photo from camera
                if case let PathForItem.remoteUrl(preview) = self.inputItem.patchToPreview {
                    self.outputItem?.metaData?.mediumUrl = preview
                }
                self.addToRemoteAlbumsIfNeeded { [weak self] in
                    guard let self = self else {
                        fail(ErrorResponse.string(TextConstants.errorUnknown))
                        return
                    }
                    
                    self.mediaItemsService.updateLocalItemSyncStatus(item: self.inputItem, newRemote: self.outputItem)
                    
                    success()
                }
                debugLog("_upload: notified about remote \(self.outputItem?.uuid ?? "_EMPTY_") ")
            }
        }, fail: fail)
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
    
    private func addPhotoToTheAlbum(with parameters: UploadRequestParametrs, response: SearchItemResponse) {
        if isPhotoAlbum {
            let item = Item(remote: response)
            let parameter = AddPhotosToAlbum(albumUUID: parameters.rootFolder, photos: [item])
            
            self.remoteAlbumsService.addPhotosToAlbum(parameters: parameter, success: {
                ItemOperationManager.default.fileAddedToAlbum(item: item)
            }, fail: { error in
                UIApplication.showErrorAlert(message: TextConstants.failWhileAddingToAlbum)
                ItemOperationManager.default.fileAddedToAlbum(item: item, error: true)
            })
        }
    }
    
    
    //MARK: - Requests
    
    private func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail: FailResponse?) -> URLSessionTask {
        return UploadService.default.baseUrl(success: success, fail: fail)
    }
    
    private func upload(uploadParam: UploadRequestParametrs, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask? {
        return UploadService.default.upload(uploadParam: uploadParam,
                                            success: success,
                                            fail: fail)
    }
    
    private func resumableUpload(uploadParam: ResumableUpload, handler: @escaping ResumableUploadHandler) -> URLSessionTask? {
        return UploadService.default.resumableUpload(uploadParam: uploadParam, handler: handler)
    }
    
    
    private func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail: FailResponse?) {
        UploadService.default.uploadNotify(param: param,
                                           success: success,
                                           fail: fail)
    }
}



//MARK: - OperationProgressServiceDelegate

extension UploadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting else {
            return
        }
        
        let actualRatio: Float
        if isResumable, let range = chunker?.lastRange {
            let bytesUploaded = range.lowerBound + bytes
            actualRatio = Float(bytesUploaded) / Float(inputItem.fileSize.intValue)
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

/// Albums Sync
extension UploadOperation {
    private func createAlbumsIfNeeded(completion: @escaping VoidHandler) {
        guard
            uploadType == .autoSync,
            !isPhotoAlbum,
            let coreDataId = inputItem.coreDataObjectId
        else {
            completion()
            return
        }
        
        mediaAlbumsService.getLocalAlbumsToSync(for: coreDataId) { [weak self] localAlbums in
            guard !localAlbums.isEmpty else {
                completion()
                return
            }
            
            self?.remoteAlbumsService.createAlbums(names: localAlbums.compactMap { $0.name }, success: { [weak self] remoteAlbums in
                self?.mediaAlbumsService.saveNewRemoteAlbums(albumItems: remoteAlbums, completion: {
                    completion()
                })
            }, fail: { _ in
                /// any album wasn't created
                completion()
            })
        }
    }
    
    private func addToRemoteAlbumsIfNeeded(completion: @escaping VoidHandler) {
        guard
            uploadType == .autoSync,
            !isPhotoAlbum,
            let coreDataId = inputItem.coreDataObjectId,
            let remote = outputItem
        else {
            completion()
            return
        }
        
        mediaItemsService.mediaItemsByIDs(ids: [coreDataId]) { [weak self] items in
            guard
                let self = self,
                let item = items.first,
                let localAlbums = item.localAlbums?.array as? Array<MediaItemsLocalAlbum>
            else {
                completion()
                return
            }
            
            let remoteAlbumsToAddInto = localAlbums
                .filter { $0.isEnabled }
                .compactMap { $0.relatedRemote?.uuid }
                .filter { !item.albumsUUIDs.contains($0) }
            
            self.remoteAlbumsService.addItem(item: remote, to: remoteAlbumsToAddInto, completion: completion)
        }
    }
}
