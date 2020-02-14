//
//  UploadOperation.swift
//  Depo
//
//  Created by Konstantin on 4/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


typealias UploadOperationSuccess = (_ uploadOperation: UploadOperation) -> Void
typealias UploadOperationHandler = (_ uploadOperation: UploadOperation, _ value: ErrorResponse?) -> Void
typealias ResumableUploadHandler = (_ completed: Bool, _  bytesUploaded: Int?, _ error: ErrorResponse?) -> Void

final class UploadOperation: Operation {
    
    typealias UploadParametersResponse = (UploadRequestParametrs) -> Void
    
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
    private let chunker: DataChunkProvider?
    private let showCustomProgress: Bool
    private let defaults: StorageVars = factory.resolve()
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
        self.isResumable = item.fileSize > NumericConstants.resumableUploadBufferSize
        
        if isResumable, let localUrl = inputItem.urlToFile {
            self.chunker = DataChunkProvider.createWithStream(url: localUrl)
            self.showCustomProgress = true
        } else {
            self.chunker = nil
            self.showCustomProgress = false
        }
        
        let interruptedUUID = self.inputItem.getTrimmedLocalID()
        self.interruptedId = self.defaults.interruptedResumableUploads[interruptedUUID] as? String
        
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
        
        if !showCustomProgress {
            SingletonStorage.shared.progressDelegates.add(self)
        }
        
        attemptUpload()
        
        semaphore.wait()
        
        clearingAction?()
        SingletonStorage.shared.progressDelegates.remove(self)
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
    
    private func retry(block: @escaping VoidHandler) {
        let delay: DispatchTime = .now() + .seconds(NumericConstants.secondsBeetweenUploadAttempts)
        dispatchQueue.asyncAfter(deadline: delay, execute: {
            self.attemptsCount += 1
            block()
        })
    }
    

    //MARK: - Resumable

    private func attemptResumableUpload(success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        requestObject = baseUrl(success: { [weak self] baseurlResponse in
            guard let self = self,
                let baseURL = baseurlResponse?.url else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
            }
            
            self.getUploadParameters(baseURL: baseURL, simple: true, success: { [weak self] parameters in
                guard let self = self, let resumableParameters = parameters as? ResumableUpload else {
                    fail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
                }
                
                self.checkResumeStatus(parameters: resumableParameters) { [weak self] isFinished, bytesUploaded, error in
                    guard let self = self else {
                        fail(ErrorResponse.string(TextConstants.commonServiceError))
                        return
                    }
                    
                    guard !isFinished else {
                        self.finishUploading(parameters: resumableParameters, success: success, fail: fail)
                        return
                    }
                      
                    guard let bytesToSkip = bytesUploaded else {
                        let error = error ?? ErrorResponse.string(TextConstants.commonServiceError)
                        fail(error)
                        return
                    }
                    
                    guard let nextChunk = self.chunker?.nextChunk(skipping: bytesToSkip) else {
                        fail(ErrorResponse.string(TextConstants.commonServiceError))
                        return
                    }
                    
                    self.defaults.interruptedResumableUploads[self.inputItem.getTrimmedLocalID()] = resumableParameters.tmpUUID
                    
                    self.uploadContiniously(parameters: resumableParameters, chunk: nextChunk, success: success, fail: fail)
                }
                
            }, fail: fail)
            
        }, fail: fail)
    }
    
    private func checkResumeStatus(parameters: ResumableUpload, handler: @escaping ResumableUploadHandler) {
        requestObject = resumableUpload(uploadParam: parameters, handler: { [weak self] isFinished, bytesUploaded, error in
            guard let self = self else {
                handler(false, nil, ErrorResponse.string(TextConstants.commonServiceError))
                return
            }
            
            if let error = error, !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                self.retry { [weak self] in
                    self?.checkResumeStatus(parameters: parameters, handler: handler)
                }
                return
            }
            
            self.attemptsCount = 0
            handler(isFinished, bytesUploaded, error)
        })
    }
    
    private func uploadContiniously(parameters: ResumableUpload, chunk: DataChunk? = nil, success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        if let chunk = chunk {
            parameters.update(chunk: chunk)
        }
        
        requestObject = resumableUpload(uploadParam: parameters, handler: { [weak self] isFinished, bytesUploaded, error in
            guard let self = self else {
                fail(ErrorResponse.string(TextConstants.commonServiceError))
                return
            }
            
            guard !isFinished else {
                self.finishUploading(parameters: parameters, success: success, fail: fail)
                return
            }
             
            if let error = error {
                if !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                    self.retry { [weak self] in
                        self?.uploadContiniously(parameters: parameters, chunk: chunk, success: success, fail: fail)
                    }
                } else {
                    fail(error)
                }
                return
            }
            
            guard let nextChunk = self.chunker?.nextChunk() else {
                fail(ErrorResponse.string(TextConstants.commonServiceError))
                return
            }
            
            self.attemptsCount = 0
            self.showProgress(uploaded: nextChunk.range.upperBound)
            self.uploadContiniously(parameters: parameters, chunk: nextChunk, success: success, fail: fail)
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
            
            let uuidToClear = self.inputItem.getTrimmedLocalID()
            self.defaults.interruptedResumableUploads[uuidToClear] = nil
            
            self.handler?(self, nil)
            self.semaphore.signal()
        }
        
        let customFail: FailResponse = { [weak self] value in
            guard let self = self else {
                return
            }
            
            let errorResponse = self.isCancelled ? ErrorResponse.string(TextConstants.canceledOperationTextError) : value
            
            self.handler?(self, errorResponse)
            self.semaphore.signal()
        }
        
        if isResumable {
            attemptResumableUpload(success: customSucces, fail: customFail)
        } else {
            attemptSimpleUpload(success: customSucces, fail: customFail)
        }
    }
    
    private func getUploadParameters(baseURL: URL, simple: Bool = false, success: @escaping UploadParametersResponse, fail: @escaping FailResponse) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                fail(ErrorResponse.string(TextConstants.errorUnknown))
                return
            }
            
            let parameters: UploadRequestParametrs
            
            if self.isResumable {
                parameters = ResumableUpload(item: self.inputItem,
                                             simple: simple,
                                             interruptedUploadId: self.interruptedId,
                                             destitantion: baseURL,
                                             uploadStategy: self.uploadStategy,
                                             uploadTo: self.uploadTo,
                                             rootFolder: self.folder,
                                             isFavorite: self.isFavorites)
            } else {
                parameters = SimpleUpload(item: self.inputItem,
                                          destitantion: baseURL,
                                          uploadStategy: self.uploadStategy,
                                          uploadTo: self.uploadTo,
                                          rootFolder: self.folder,
                                          isFavorite: self.isFavorites)
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
                
                if let response = baseurlResponse as? SearchItemResponse {
                    self.outputItem = WrapData(remote: response)
                    self.addPhotoToTheAlbum(with: parameters, response: response)
                    self.outputItem?.tmpDownloadUrl = response.tempDownloadURL
                    self.outputItem?.metaData?.takenDate = self.inputItem.metaDate
                    self.outputItem?.metaData?.duration = self.inputItem.metaData?.duration ?? Double(0.0)
                    
                    //case for upload photo from camera
                    if case let PathForItem.remoteUrl(preview) = self.inputItem.patchToPreview {
                        self.outputItem?.metaData?.mediumUrl = preview
                    }
                    
                    MediaItemOperationsService.shared.updateLocalItemSyncStatus(item: self.inputItem, newRemote: self.outputItem)
                }
                
                success()
            }
        }, fail: fail)
    }
    
    private func addPhotoToTheAlbum(with parameters: UploadRequestParametrs, response: SearchItemResponse) {
        if self.isPhotoAlbum {
            let item = Item(remote: response)
            let parameter = AddPhotosToAlbum(albumUUID: parameters.rootFolder, photos: [item])
            
            PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: {
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
    
    //Custom Progress
    private func showProgress(uploaded: Int) {
        guard isExecuting, let fileSize = chunker?.fileSize, let uploadType = uploadType else {
            return
        }
        
        let ratio = Float(uploaded) / Float (fileSize)
        
        CardsManager.default.setProgress(ratio: ratio, operationType: UploadService.convertUploadType(uploadType: uploadType), object: inputItem)
        ItemOperationManager.default.setProgressForUploadingFile(file: inputItem, progress: ratio)
    }
}



//MARK: - OperationProgressServiceDelegate

extension UploadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, for url: URL) {
        guard isExecuting else {
            return
        }

        if requestObject?.currentRequest?.url == url, let uploadType = uploadType {
            CardsManager.default.setProgress(ratio: ratio, operationType: UploadService.convertUploadType(uploadType: uploadType), object: inputItem)
            ItemOperationManager.default.setProgressForUploadingFile(file: inputItem, progress: ratio)
        }
    }
}
