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


final class UploadOperation: Operation {
    
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
        
        super.init()
        self.qualityOfService = (uploadType == .autoSync) ? .background : .userInitiated
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
        attempmtUpload()
        
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
    
    private func attempmtUpload() {
        let customSucces: FileOperationSucces = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.handler?(self, nil)
            self.semaphore.signal()
        }
        
        let customFail: FailResponse = { [weak self] value in
            guard let `self` = self else {
                return
            }
            
            let errorResponse = self.isCancelled ? ErrorResponse.string(TextConstants.canceledOperationTextError) : value
            
            self.handler?(self, errorResponse)
            self.semaphore.signal()
        }
        
        guard !isCancelled else {
            customFail(ErrorResponse.string(TextConstants.canceledOperationTextError))
            return
        }
        
        requestObject = baseUrl(success: { [weak self] baseurlResponse in
            guard let `self` = self,
                let baseurlResponse = baseurlResponse,
                let responseURL = baseurlResponse.url else {
                    customFail(ErrorResponse.string(TextConstants.commonServiceError))
                    return
            }
            
            self.dispatchQueue.async { [weak self] in
                guard let `self` = self else {
                    return
                }

                let uploadParam = Upload(item: self.inputItem,
                                         destitantion: responseURL,
                                         uploadStategy: self.uploadStategy,
                                         uploadTo: self.uploadTo,
                                         rootFolder: self.folder,
                                         isFavorite: self.isFavorites,
                                         uploadType: self.uploadType)
                
                self.clearingAction = { [weak self] in
                    self?.removeTemporaryFile(at: uploadParam.urlToLocalFile)
                }
                
                self.requestObject = self.upload(uploadParam: uploadParam, success: { [weak self] in
                    
                    let uploadNotifParam = UploadNotify(parentUUID: uploadParam.rootFolder,
                                                        fileUUID: uploadParam.tmpUUId )
                    
//                    self?.inputItem.uuid = uploadParam.tmpUUId
                    self?.inputItem.syncStatus = .synced
                    self?.inputItem.setSyncStatusesAsSyncedForCurrentUser()
                    
                    self?.uploadNotify(param: uploadNotifParam, success: { [weak self] baseurlResponse in
                        self?.dispatchQueue.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            
                            if let response = baseurlResponse as? SearchItemResponse {
                                self.outputItem = WrapData(remote: response)
                                self.addPhotoToTheAlbum(with: uploadParam, response: response)
                                self.outputItem?.tmpDownloadUrl = response.tempDownloadURL
                                self.outputItem?.metaData?.takenDate = self.inputItem.metaDate
                                self.outputItem?.metaData?.duration = self.inputItem.metaData?.duration ?? Double(0.0)
                                
                                //case for upload photo from camera
                                if case let PathForItem.remoteUrl(preview) = self.inputItem.patchToPreview {
                                    self.outputItem?.metaData?.mediumUrl = preview
                                }

                                MediaItemOperationsService.shared.updateLocalItemSyncStatus(item: self.inputItem, newRemote: self.outputItem)
                            }
                            
                            customSucces()
                        }
                    }, fail: customFail)
                    
                }, fail: { [weak self] error in
                    guard let `self` = self else {
                        return
                    }
                    
                    if !self.isCancelled, error.isNetworkError, self.attemptsCount < NumericConstants.maxNumberOfUploadAttempts {
                        let delay: DispatchTime = .now() + .seconds(NumericConstants.secondsBeetweenUploadAttempts)
                        self.dispatchQueue.asyncAfter(deadline: delay, execute: {
                            self.attemptsCount += 1
                            self.attempmtUpload()
                        })
                    } else {
                        customFail(error)
                    }
                })
                
                ///If upload service can't create upload request task for some reason
                if self.requestObject == nil {
                    customFail(ErrorResponse.string(TextConstants.commonServiceError))
                }
            }
            
            }, fail: customFail)
    }
    
    private func addPhotoToTheAlbum(with parameters: Upload, response: SearchItemResponse) {
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
    
    private func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask? {
        return UploadService.default.upload(uploadParam: uploadParam,
                                            success: success,
                                            fail: fail)
    }
    
    private func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail: FailResponse?) {
        UploadService.default.uploadNotify(param: param,
                                           success: success,
                                           fail: fail)
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
