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

    private let dispatchQueue = DispatchQueue(label: "com.lifebox.upload")
    
    private let uploadQueue = OperationQueue()
    private var uploadOperations = [UploadOperations]()
    
    private var allSyncOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .autoSync }).count + finishedSyncOperationsCount
    }
    private var allUploadOperationsCount = 0
    
    private var finishedSyncOperationsCount : Int {
        return finishedPhotoSyncOperationsCount + finishedVideoSyncOperationsCount
    }
    private var finishedPhotoSyncOperationsCount = 0
    private var finishedVideoSyncOperationsCount = 0
    private var finishedUploadOperationsCount = 0

    
    override init() {
        uploadQueue.maxConcurrentOperationCount = 1
    
        super.init()
        SingletonStorage.shared.uploadProgressDelegate = self
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
        //TODO: add .syncTouse case with the higher priority
        default:
            return self.uploadFileList(items: items, uploadStategy: uploadStategy, uploadTo: uploadTo, needsSuccess: uploadType == .syncToUse, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: {

                success?()
            }, fail: { [weak self] (errorResponse) in
                guard let `self` = self else {
                    return
                }
                
                if case ErrorResponse.httpCode(413) = errorResponse {
                    self.cancelUploadOperations()
                    self.showOutOfSpaceAlert()
                }
                
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
                    }
                    return false
                }
                return operation.item.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToUpload.isEmpty else {
            return nil
        }
        
        CardsManager.default.startOperationWith(type: .upload, allOperations: itemsToUpload.count, completedOperations: 0)
        self.allUploadOperationsCount += itemsToUpload.count
        
        let firstObject = itemsToUpload.first!
        
        ItemOperationManager.default.startUploadFile(file: firstObject)
        CardsManager.default.setProgressForOperationWith(type: .upload,
                                                                    object: firstObject,
                                                                    allOperations: self.allUploadOperationsCount,
                                                                    completedOperations: self.finishedUploadOperationsCount)
        
        let operations: [UploadOperations] = itemsToUpload.flatMap {
            let operation = UploadOperations(item: $0, uploadType: .fromHomePage, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] (finishedOperation, error) in
                guard let `self` = self else {
                    return
                }
                
                self.finishedUploadOperationsCount += 1
                
                if let index = self.uploadOperations.index(of: finishedOperation){
                    self.uploadOperations.remove(at: index)
                }
                
                CardsManager.default.setProgressForOperationWith(type: .upload,
                                                                            object: nil,
                                                                            allOperations: self.allUploadOperationsCount,
                                                                            completedOperations: self.finishedUploadOperationsCount)
                
                if let error = error {
                    
                    //FIXME: remove needsSuccess flag, implement logic with a higher priority operations for the .syncToUse case
                    if needsSuccess {
                        success?()
                    } else {
                        fail?(error)
                    }
                    
                    if self.allUploadOperationsCount == self.finishedUploadOperationsCount {
                        self.clearUploadCounters()
                        self.uploadOperations = self.uploadOperations.filter({ $0.uploadType == .autoSync })
                        CardsManager.default.stopOperationWithType(type: .upload)
                    }
                    return
                }
                
                
                finishedOperation.item.syncStatus = .synced
                finishedOperation.item.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                finishedOperation.item.isLocalItem = false

                CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)
                
                ItemOperationManager.default.finishedUploadFile(file: finishedOperation.item)

                guard self.allUploadOperationsCount != 0 else {
                    return
                }
                
                if self.allUploadOperationsCount == self.finishedUploadOperationsCount {
                    self.clearUploadCounters()
                    CardsManager.default.stopOperationWithType(type: .upload)
                    success?()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UploadService.notificatioUploadServiceDidUpload),
                                                object: nil)
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
    
    @discardableResult private func syncFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse) -> [UploadOperations]? {
        // filter all items which md5's are not in the uploadOperations
        let itemsToSync = items.filter { (item) -> Bool in
            return (self.uploadOperations.first(where: { (operation) -> Bool in
                return operation.item.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToSync.isEmpty else {
            return nil
        }
//        if allSyncOperationsCount == 0 {
//            CardsManager.default.startOperationWith(type: .sync, allOperations: self.allSyncOperationsCount + itemsToSync.count, completedOperations: 0)
//        }
        
        let firstObject = itemsToSync.first!
        print("AUTOSYNC: trying to add \(itemsToSync.count) item(s) of \(firstObject.fileType) type")
        CardsManager.default.setProgressForOperationWith(type: .sync,
                                                                    object: firstObject,
                                                                    allOperations: self.allSyncOperationsCount + itemsToSync.count,
                                                                    completedOperations: self.finishedSyncOperationsCount)
        
        ItemOperationManager.default.startUploadFile(file: firstObject)
        
        let operations: [UploadOperations] = itemsToSync.flatMap {
            
            let operation = UploadOperations(item: $0, uploadType: .autoSync, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] (finishedOperation, error) in
                guard let `self` = self else {
                    return
                }
                
                if finishedOperation.item.fileType == .image { self.finishedPhotoSyncOperationsCount += 1 }
                else if finishedOperation.item.fileType == .video { self.finishedVideoSyncOperationsCount += 1 }
                
                if let index = self.uploadOperations.index(of: finishedOperation){
                    self.uploadOperations.remove(at: index)
                }
                
                CardsManager.default.setProgressForOperationWith(type: .sync,
                                                                            object: nil,
                                                                            allOperations: self.allSyncOperationsCount,
                                                                            completedOperations: self.finishedSyncOperationsCount)
                
                
                if let error = error {
                    if error.description != TextConstants.canceledOperationTextError {
                        print(error.localizedDescription)
                        fail(error)
                        return
                    }
                    
                    
                    if self.allSyncOperationsCount != 0, self.allSyncOperationsCount == self.finishedSyncOperationsCount {
                        print("allSyncOperationsCount = \(self.allSyncOperationsCount), finishedSyncOperationsCount = \(self.finishedSyncOperationsCount)")
                        self.clearSyncCounters()
                        self.uploadOperations = self.uploadOperations.filter({ $0.uploadType != .autoSync })
                        CardsManager.default.stopOperationWithType(type: .sync)
                        success()
                        return
                    }
                }

                finishedOperation.item.syncStatus = .synced
                finishedOperation.item.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)
                
                ItemOperationManager.default.finishedUploadFile(file: finishedOperation.item)
                
                guard self.allSyncOperationsCount != 0, self.finishedSyncOperationsCount != 0 else {
                    return
                }
                
                if self.allSyncOperationsCount == self.finishedSyncOperationsCount {
                    self.clearSyncCounters()
                    CardsManager.default.stopOperationWithType(type: .sync)
                    success()
                    return
                }
                
            })
            
            operation.queuePriority = .normal
            return operation
        }
        uploadOperations.append(contentsOf: operations)
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            print("AUTOSYNC: \(operations.count) \(firstObject.fileType)(s) have been added to the sync queue")
        }
        
        return uploadOperations
    }
    
    func cancelOperations(){
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        
        clearUploadCounters()
        clearSyncCounters()
        
        CardsManager.default.stopOperationWithType(type: .upload)
        CardsManager.default.stopOperationWithType(type: .sync)
    }
    
    func cancelUploadOperations(){
        var operationsToRemove = uploadOperations.filter({ $0.uploadType == .fromHomePage })
        operationsToRemove.forEach { (operation) in
            operation.cancel()
            if let index = uploadOperations.index(of: operation) {
                uploadOperations.remove(at: index)
            }
        }
        operationsToRemove.removeAll()
        
        clearUploadCounters()
        
        CardsManager.default.stopOperationWithType(type: .upload)
    }
    
    func cancelSyncOperations(photo: Bool, video: Bool) {
        dispatchQueue.sync {
            print("AUTOSYNC: cancelling sync operations for \(photo ? "photo" : "video")")
            
            var operationsToRemove = self.uploadOperations.filter({ $0.uploadType == .autoSync &&
                ((video && $0.item.fileType == .video) || (photo && $0.item.fileType == .image)) })
            
            operationsToRemove.forEach { (operation) in
                operation.cancel()
                if let index = self.uploadOperations.index(of: operation) {
                    self.uploadOperations.remove(at: index)
                }
            }
            print("AUTOSYNC: \(operationsToRemove.count) operations have been deleted")
            operationsToRemove.removeAll()
            
            self.resetSyncCounters(for: photo ? .image : .video)
            
            guard self.allSyncOperationsCount != self.finishedSyncOperationsCount else {
                CardsManager.default.stopOperationWithType(type: .sync)
                return
            }
            
            CardsManager.default.setProgressForOperationWith(type: .sync, allOperations: self.allSyncOperationsCount, completedOperations: self.finishedSyncOperationsCount)
        }
    }
    
    private func clearUploadCounters() {
        allUploadOperationsCount = 0
        finishedUploadOperationsCount = 0
    }
    
    private func clearSyncCounters() {
        print("AUTOSYNC: clearing sync counters")
        finishedPhotoSyncOperationsCount = 0
        finishedVideoSyncOperationsCount = 0
    }
    
    private func resetSyncCounters(for type: FileType) {
        print("AUTOSYNC: reseting sync counters for \(type) type")
        if type == .image { finishedPhotoSyncOperationsCount = 0 }
        else if type == .video { finishedVideoSyncOperationsCount = 0 }
    }
    
    func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask {
    
        let request = executeUploadRequest(param: uploadParam, response: { (data, response, error) in
            
            guard error == nil else {
                fail?(.error(error!))
                return
            }
            
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

extension UploadService: UploadProgressServiceDelegate {

    func didSend(ratio: Float, for tempUUID: String) {
        if let uploadOperation = uploadOperations.first(where: {$0.item.uuid == tempUUID}){
            if let uploadType = uploadOperation.uploadType{
                CardsManager.default.setProgress(ratio: ratio, operationType: UploadService.convertUploadType(uploadType: uploadType), object: uploadOperation.item)
            }
            ItemOperationManager.default.setProgressForUploadingFile(file: uploadOperation.item, progress: ratio)
        }
    }
}

extension UploadService {
    fileprivate func showOutOfSpaceAlert() {
        let controller = PopUpController.with(title: TextConstants.syncOutOfSpaceAlertTitle,
                                              message: TextConstants.syncOutOfSpaceAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.syncOutOfSpaceAlertCancel,
                                              secondButtonTitle: TextConstants.syncOutOfSpaceAlertGoToSettings,
                                              firstAction: nil,
                                              secondAction: { vc in
                                                vc.close(completion: {
                                                    let router = RouterVC()
                                                    router.pushViewController(viewController: router.packages)
                                                })
        })
        
        DispatchQueue.main.async {
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        }
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
    var requestObject: URLSessionTask?
    let handler: ((_ uploadOberation: UploadOperations, _ value: ErrorResponse?) -> Void)?
    var isRealCancel = false
    var isFavorites: Bool = false
    var isPhotoAlbum: Bool = false
    
    private let semaphore: DispatchSemaphore
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, handler: @escaping (_ uploadOberation: UploadOperations, _ value: ErrorResponse?)->Void) {
        self.item = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.handler = handler
        self.success = nil
        self.fail = nil
        self.semaphore = DispatchSemaphore(value: 0)
        self.isFavorites = isFavorites
        self.isPhotoAlbum = isFromAlbum
        
        super.init()
        self.qualityOfService = (uploadType == .autoSync) ? .background : .userInitiated
        
    }
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: UploadOperationSuccess?, fail: FailResponse?) {
        self.item = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.success = success
        self.fail = fail
        self.handler = nil
        self.semaphore = DispatchSemaphore(value: 0)
        self.isFavorites = isFavorites
        self.isPhotoAlbum = isFromAlbum
        
        super.init()
        self.qualityOfService = (uploadType == .autoSync) ? .default : .userInitiated
        
    }
    
    override func cancel() {
        super.cancel()
        if let req = requestObject {
            if (req.state == .running) || (req.state == .suspended){
                req.cancel()
                isRealCancel = true
            }
        } else {
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
        
        if isCancelled {
            return
        }
        
        let customSucces: FileOperationSucces = {
            self.success?(self)
            self.handler?(self, nil)
            self.semaphore.signal()
        }
        
        let customFail: FailResponse = { value in
            self.fail?(value)
            self.handler?(self, value)
            self.semaphore.signal()
        }
        
        ItemOperationManager.default.startUploadFile(file: item)
        
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
                    if let localURL = uploadParam.urlToLocalFile {
                        try? FileManager.default.removeItem(at: localURL)
                    }
                    
                    if isPhotoAlbum_{
                        if let resp = baseurlResponse as? SearchItemResponse{
                            let item = Item.init(remote: resp)
                            let parameter = AddPhotosToAlbum(albumUUID: uploadParam.rootFolder, photos: [item])
                            PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: {
                                ItemOperationManager.default.fileAddedToAlbum()
                            }, fail: { (error) in
                                UIApplication.showErrorAlert(message: TextConstants.failWhileAddingToAlbum)
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
    
    private func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? )-> URLSessionTask {
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

