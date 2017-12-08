//
//  UploadService.swift
//  Depo
//
//  Created by Alexander Gurin on 1/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UploadService: BaseRequestService {
    
    static let `default` = UploadService()
    
    static let notificatioUploadServiceDidUpload = "notificatioUploadServiceDidUpload"

    private let dispatchQueue: DispatchQueue
//    private let syncDispatchQueue: DispatchQueue
    
    private let uploadQueue: OperationQueue
    private var uploadOperations = [UploadOperations]()
    
    private var allSyncOperationsCount = 0
    private var allUploadOperationsCount = 0
    
    private var finishedSyncOperationsCount = 0
    private var finishedUploadOperationsCount = 0

    
    override init() {
        
        uploadQueue = OperationQueue()
        uploadQueue.qualityOfService = .background
        uploadQueue.maxConcurrentOperationCount = 1
    
        dispatchQueue = DispatchQueue(label: "Upload Queue")
//        syncDispatchQueue = DispatchQueue(label: "Sync Queue")
        
        super.init()
    }

    func upload(imageData: Data, parentUUID: String = "", isFaorites: Bool = false, handler: @escaping (Result<SearchItemResponse>) -> Void) {
        baseUrl(success: { [weak self] urlResponse in
            
            guard let url = urlResponse?.url else {
                return handler(.failed(CustomErrors.unknown))
            }
            
            let uploadParam = UploadDataParametrs(data: imageData, url: url)
            uploadParam.parentUuid = parentUUID
            uploadParam.isFavorites = isFaorites
            
            _ = self?.executeUploadDataRequest(param: uploadParam, response: { [weak self]
                (data, response, error) in
                
                if let error = error {
                    return handler(.failed(error))
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 300 {
                    return handler(.failed(ServerError(code: httpResponse.statusCode, data: data)))
                }
                guard let _ = data else {
                    return handler(.failed(CustomErrors.unknown))
                }
                
                let uploadNotifParam = UploadNotify(parentUUID: parentUUID,
                                                    fileUUID: uploadParam.tmpUUId )

                self?.uploadNotify(param: uploadNotifParam, success: { baseurlResponse in
                    guard let response = baseurlResponse as? SearchItemResponse else {
                        return handler(.failed(CustomErrors.unknown))
                    }

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UploadService.notificatioUploadServiceDidUpload),
                                                    object: nil)
                    handler(.success(response))
                }, fail: { errorResponse in
                    handler(.failed(CustomErrors.text(errorResponse.description)))
                })
            })
        }, fail: { errorResponse in
            handler(.failed(CustomErrors.text(errorResponse.description)))
        })
    }

    
    //MARK: -
    class func convertUploadType(uploadType: UploadType) -> OperationType{
        switch uploadType {
        case .autoSync:
            return .sync
        default:
            return .upload
        }
    }
    
    @discardableResult func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: FileOperationSucces?, fail: FailResponse? ) -> [UploadOperations]? {
        switch uploadType {
        case .autoSync:
            return self.syncFileList(items: items, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: {
                success?()
            }, fail: { (errorResponse) in
                fail?(errorResponse)
            })
        default:
            return self.uploadFileList(items: items, uploadStategy: uploadStategy, uploadTo: uploadTo, needsSuccess: uploadType == .syncToUse, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: {
                success?()
            }, fail: { (errorResponse) in
                fail?(errorResponse)
            })
        }
    
    }
    
    @discardableResult private func uploadFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, needsSuccess: Bool = false, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: FileOperationSucces?, fail: FailResponse? ) -> [UploadOperations]? {
        // filter all items which md5's are not in the uploadOperations
        let itemsToUpload = items.filter { (item) -> Bool in
            return (self.uploadOperations.first(where: { (operation) -> Bool in
                if operation.item.md5 == item.md5 && operation.uploadType == .autoSync && !operation.isExecuting {
                    operation.cancel()
                    if let index = self.uploadOperations.index(of: operation){
                        self.uploadOperations.remove(at: index)
                        self.allSyncOperationsCount -= 1
                    }
                    return false
                }
                return operation.item.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToUpload.isEmpty else {
            return nil
        }
        
        WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: itemsToUpload.count, completedOperations: 0)
        self.allUploadOperationsCount += itemsToUpload.count
        WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload,
                                                                    allOperations: self.allUploadOperationsCount,
                                                                    completedOperations: self.finishedUploadOperationsCount)
        
        let operations: [UploadOperations] = itemsToUpload.flatMap {
            let operation = UploadOperations(item: $0, uploadType: .fromHomePage, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { (finishedOperation) in
                finishedOperation.item.syncStatus = .synced
                finishedOperation.item.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                finishedOperation.item.isLocalItem = false
                CoreDataStack.default.appendOnlyNewItems(items: [finishedOperation.item])
                
                guard self.allUploadOperationsCount != 0 else {
                    return
                }
                self.finishedUploadOperationsCount += 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload,
                                                                            allOperations: self.allUploadOperationsCount,
                                                                            completedOperations: self.finishedUploadOperationsCount)
                
                if let index = self.uploadOperations.index(of: finishedOperation){
                    self.uploadOperations.remove(at: index)
                }
                
                if self.allUploadOperationsCount == self.finishedUploadOperationsCount {
                    self.clearUlpoadCounters()
                    WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
                    success?()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UploadService.notificatioUploadServiceDidUpload),
                                                object: nil)
            }, fail: { (operationFail) in
                self.finishedUploadOperationsCount += 1
                
                if self.allUploadOperationsCount == self.finishedUploadOperationsCount {
                    self.clearUlpoadCounters()
                    self.uploadOperations = self.uploadOperations.flatMap({
                        if $0.uploadType == .autoSync {
                            return $0
                        }
                        return nil
                    })
                    WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
                    if !needsSuccess {
                        success?()
                    } else {
                        fail?(operationFail)
                    }
                    
                }
            })
            operation.queuePriority = .high
            return operation
        }
        uploadOperations.insert(contentsOf: operations, at: 0)
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            print("UPLOADING upload: \(operations.count) have been added to the upload queue")
        }
        
        return operations
    }
    
    @discardableResult private func syncFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: FileOperationSucces?, fail: FailResponse? ) -> [UploadOperations]? {
        // filter all items which md5's are not in the uploadOperations
        let itemsToSync = items.filter { (item) -> Bool in
            return (self.uploadOperations.first(where: { (operation) -> Bool in
                return operation.item.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToSync.isEmpty else {
            return nil
        }
        
        WrapItemOperatonManager.default.startOperationWith(type: .sync, allOperations: itemsToSync.count, completedOperations: 0)
        self.allSyncOperationsCount += itemsToSync.count
        WrapItemOperatonManager.default.setProgressForOperationWith(type: .sync,
                                                                    allOperations: self.allSyncOperationsCount,
                                                                    completedOperations: self.finishedSyncOperationsCount)
        let operations: [UploadOperations] = itemsToSync.flatMap {
            let operation = UploadOperations(item: $0, uploadType: .autoSync, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { (finishedOperation) in
                
                finishedOperation.item.syncStatus = .synced
                finishedOperation.item.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)//appendOnlyNewItems(items: [finishedOperation.item])
                
                guard self.allSyncOperationsCount != 0 else {
                    return
                }
                
                self.finishedSyncOperationsCount += 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .sync,
                                                                            allOperations: self.allSyncOperationsCount,
                                                                            completedOperations: self.finishedSyncOperationsCount)
                if let index = self.uploadOperations.index(of: finishedOperation){
                    self.uploadOperations.remove(at: index)
                }
                
                if self.allSyncOperationsCount == self.finishedSyncOperationsCount {
                    self.clearSyncCounters()
                    WrapItemOperatonManager.default.stopOperationWithType(type: .sync)
                    success?()
                }
                
            }, fail: { (fail) in
                if fail.description != TextConstants.canceledOperationTextError{
                    self.finishedSyncOperationsCount += 1
                }
                
                if self.allSyncOperationsCount == self.finishedSyncOperationsCount {
                    self.clearSyncCounters()
                    self.uploadOperations = self.uploadOperations.flatMap({
                        if $0.uploadType != .autoSync {
                            return $0
                        }
                        return nil
                    })
                    WrapItemOperatonManager.default.stopOperationWithType(type: .sync)
                    success?()
                }
                
            })
            operation.queuePriority = .normal
            return operation
        }
        uploadOperations.append(contentsOf: operations)
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            print("UPLOADING sync: \(operations.count) have been added to the sync queue")
        }
        
        return uploadOperations
    }
    
    func cancelOperations(){
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        
        clearUlpoadCounters()
        clearSyncCounters()
        
        WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
        WrapItemOperatonManager.default.stopOperationWithType(type: .sync)
    }
    
    private func clearUlpoadCounters() {
        allUploadOperationsCount = 0
        finishedUploadOperationsCount = 0
    }
    
    private func clearSyncCounters() {
        allSyncOperationsCount = 0
        finishedSyncOperationsCount = 0
    }
    
    func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionUploadTask {
    
        let request = executeUploadRequest(param: uploadParam, response: { (data, response, error) in
                            
            if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    success?()
                    return
                } else {
                    fail?(.httpCode(httpResponse.statusCode))
                    return
                }
            }
                                
            fail?(.string("Error upload"))
        })
        
        return request
    }
    
    func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail:FailResponse?) {
        let param = UploadBaseURL()
        let handler = BaseResponseHandler<UploadBaseURLResponse, ObjectRequestResponse>(success: { result in
           success(result as? UploadBaseURLResponse)
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail:FailResponse?) {
        let handler = BaseResponseHandler<SearchItemResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}

typealias UploadOperationSuccess = (_ uploadOberation: UploadOperations) -> Swift.Void

class UploadOperations: Operation {
    
    let item: WrapData
    var uploadType: UploadType?
    let uploadStategy: MetaStrategy
    let uploadTo: MetaSpesialFolder
    let folder: String
    let success: UploadOperationSuccess?
    let fail: FailResponse?
    var requestObject: URLSessionUploadTask?
    var isRealCancel = false
    var isFavorites: Bool = false
    var isPhotoAlbum: Bool = false
    
    private let semaphore: DispatchSemaphore
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: UploadOperationSuccess?, fail: FailResponse?) {
        self.item = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.success = success
        self.fail = fail
        self.semaphore = DispatchSemaphore(value: 0)
        self.isFavorites = isFavorites
        self.isPhotoAlbum = isFromAlbum
        
        super.init()
        self.qualityOfService = (uploadType == .autoSync) ? .background : .userInitiated
        
    }
    
    override func cancel() {
        if let req = requestObject {
            if (req.state == .running) || (req.state == .suspended){
                req.cancel()
                isRealCancel = true
            }
        }else{
            isRealCancel = true
        }
    }
    
    override func main() {
        
        let isPhotoAlbum_ = isPhotoAlbum
        
        if isRealCancel {
            if let req = requestObject {
                req.cancel()
            }
            
            if let fail_ = self.fail{
                fail_(ErrorResponse.string(TextConstants.canceledOperationTextError))
            }
            
            self.semaphore.signal()
            return
        }
        
        let customSucces: FileOperationSucces = {
            self.success?(self)
            self.semaphore.signal()
        }
        
        let customFail: FailResponse = { value in
            self.fail?(value)
            self.semaphore.signal()
        }
        
        baseUrl(success: { [weak self] baseurlResponse in
            guard let `self` = self else{
                customFail(ErrorResponse.string("Unknown error"))
                return
            }
            
            let uploadParam  = Upload(item: self.item,
                                      destitantion: (baseurlResponse?.url!)!,
                                      uploadStategy: self.uploadStategy,
                                      uploadTo: self.uploadTo,
                                      rootFolder: self.folder,
                                      isFavorite: self.isFavorites)
            
            self.requestObject = self.upload(uploadParam: uploadParam, success: { [weak self] in
                
                let uploadNotifParam = UploadNotify(parentUUID: uploadParam.rootFolder,
                                                    fileUUID:uploadParam.tmpUUId )
                
                self?.uploadNotify(param: uploadNotifParam, success: { baseurlResponse in
                    try? FileManager.default.removeItem(at: uploadParam.urlToLocalFile)
                    
                    if isPhotoAlbum_{
                        if let resp = baseurlResponse as? SearchItemResponse{
                            let item = Item.init(remote: resp)
                            let parameter = AddPhotosToAlbum(albumUUID: uploadParam.rootFolder, photos: [item])
                            PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: {
                                
                            }, fail: { (error) in
                                CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.failWhileAddingToAlbum, okButtonText: TextConstants.createStoryPhotosMaxCountAllertOK)
                            })
                        }
                    }
                    
//                    if let response = baseurlResponse as? UploadNotifyResponse,
//                        let uploadedFileDetail = response.itemResponse {
//                        let wrapDataValue = WrapData(remote: uploadedFileDetail)
//                        CoreDataStack.default.appendOnlyNewItems(items: [wrapDataValue])
//                    }
                    
                    customSucces()
                    
                }, fail: customFail)
                
                }, fail: customFail)
            
            }, fail: customFail)
        
        semaphore.wait()
    }
    
    private func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail:FailResponse?) {
        UploadService.default.baseUrl(success: success, fail: fail)
    }
    
    private func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? )-> URLSessionUploadTask {
        return UploadService.default.upload(uploadParam: uploadParam,
                                            success: success,
                                            fail: fail)
    }
    
    private func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail:FailResponse?) {
        UploadService.default.uploadNotify(param: param,
                                           success: success,
                                           fail: fail)
    }
}
