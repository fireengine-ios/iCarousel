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
    
    private let dispatchQueue: DispatchQueue
    
    private let syncQueue: OperationQueue
    private let uploadQueue: OperationQueue
    private var uploadOperations = [UploadOperations]()
//    private var uploadOnDemandOperations = [UploadOperations]()
    
    override init() {
        
        uploadQueue = OperationQueue()
        uploadQueue.maxConcurrentOperationCount = 1
        syncQueue = OperationQueue()
        syncQueue.maxConcurrentOperationCount = 1
        
        dispatchQueue = DispatchQueue(label: "Upload Queue")
        super.init()
    }

    func upload(imageData: Data, handler: @escaping (Result<Void>) -> Void) {
        baseUrl(success: { [weak self] urlResponse in
            
            guard let url = urlResponse?.url else {
                return handler(.failed(CustomErrors.unknown))
            }
            
            let uploadParam = UploadDataParametrs(data: imageData, url: url)
            
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
                
                let uploadNotifParam = UploadNotify(parentUUID: "",
                                                    fileUUID: uploadParam.tmpUUId )

                self?.uploadNotify(param: uploadNotifParam, success: { baseurlResponse in
                    /// MAYBE WILL BE NEED
                    //guard let response = baseurlResponse as? UploadNotifyResponse else {
                    //    return handler(.failed(CustomErrors.unknown))
                    //}
                    //print(response.itemResponse ?? "")
                    handler(.success(()))
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
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse? ) {
        
        switch uploadType {
        case .autoSync:
            self.syncFileList(items: items, uploadStategy: uploadStategy, uploadTo: uploadTo, success: {
                
            }, fail: { (errorResponse) in
                
            })
        default:
            self.uploadFileList(items: items, uploadStategy: uploadStategy, uploadTo: uploadTo, success: {
                
            }, fail: { (errorResponse) in
                
            })
            break
        }
    
    }
    
    private func uploadFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse? ) {
        // filter all items which md5's are not in the uploadOperations
        let itemsToSync = items.filter { (item) -> Bool in
            return (self.uploadOperations.first(where: { (operation) -> Bool in
                if operation.item.md5 == item.md5 && operation.uploadType.contains(.autoSync) && !operation.isExecuting {
                    operation.cancel()
                    return true
                }
                return false
            }) == nil)
        }
        
        guard !itemsToSync.isEmpty else {
            return
        }
        
        WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: itemsToSync.count, completedOperations: 0)
        let allOperationCount = itemsToSync.count
        var completedOperationCount = 0
        let operations: [UploadOperations] = itemsToSync.flatMap {
            let operation = UploadOperations(item: $0, uploadType: .fromHomePage, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, success: { (finishedOperation) in
                completedOperationCount = completedOperationCount + 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload,
                                                                            allOperations: allOperationCount,
                                                                            completedOperations: completedOperationCount)
            }, fail: { (fail) in
                completedOperationCount = completedOperationCount + 1
            })
            operation.queuePriority = .high
            return operation
        }
        uploadOperations.append(contentsOf: operations)
        
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: true)
            success?()
            WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
        }
    }
    
    private func syncFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse? ) {
        // filter all items which md5's are not in the uploadOperations
        let itemsToSync = items.filter { (item) -> Bool in
            return (self.uploadOperations.first(where: { (operation) -> Bool in
                return operation.item.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToSync.isEmpty else {
            return
        }
        
        WrapItemOperatonManager.default.startOperationWith(type: .sync, allOperations: itemsToSync.count, completedOperations: 0)
        let allOperationCount = itemsToSync.count
        var completedOperationCount = 0
        let operations: [UploadOperations] = itemsToSync.flatMap {
            let operation = UploadOperations(item: $0, uploadType: .autoSync, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, success: { (finishedOperation) in
                completedOperationCount = completedOperationCount + 1
                    WrapItemOperatonManager.default.setProgressForOperationWith(type: .sync,
                                                                                allOperations: allOperationCount,
                                                                                completedOperations: completedOperationCount)
            }, fail: { (fail) in
                completedOperationCount = completedOperationCount + 1
            })
            operation.queuePriority = .normal
            return operation
        }
        uploadOperations.append(contentsOf: operations)
        
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: true)
            success?()
            WrapItemOperatonManager.default.stopOperationWithType(type: .sync)
        }
        
    }
    
    func cancelOperations(){
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
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
        let handler = BaseResponseHandler<UploadNotifyResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}

typealias UploadOperationSuccess = (_ uploadOberation: UploadOperations) -> Swift.Void

class UploadOperations: Operation {
    
    let item: WrapData
    var uploadType = Set<UploadType>()
    let uploadStategy: MetaStrategy
    let uploadTo: MetaSpesialFolder
    let folder: String
    let success: UploadOperationSuccess?
    let fail: FailResponse?
    var requestObject: URLSessionUploadTask?
    var isRealCancel = false
    
    private let semaphore: DispatchSemaphore
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: UploadOperationSuccess?, fail: FailResponse?) {
        self.item = item
        self.uploadType.insert(uploadType)
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.success = success
        self.fail = fail
        self.semaphore = DispatchSemaphore(value: 0)
        
        super.init()
        
        if self.queuePriority == .high{
            return
        }
        if uploadType == .autoSync {
            self.queuePriority = .normal
        }else{
            self.queuePriority = .high
        }
        
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
        
        if isRealCancel {
            if let req = requestObject {
                req.cancel()
            }
            
            if let fail_ = self.fail{
                fail_(ErrorResponse.string("Cancelled"))
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
                                      rootFolder: self.folder)
            self.requestObject = self.upload(uploadParam: uploadParam, success: { [weak self] in
                
                let uploadNotifParam = UploadNotify(parentUUID: "",
                                                    fileUUID:uploadParam.tmpUUId )
                
                self?.uploadNotify(param: uploadNotifParam, success: { baseurlResponse in
                    try? FileManager.default.removeItem(at: uploadParam.urlToLocalFile)
                    
                    if let response = baseurlResponse as? UploadNotifyResponse,
                        let uploadedFileDetail = response.itemResponse {
//                        let wrapDataValue = WrapData(remote: uploadedFileDetail)
//                        CoreDataStack.default.appendOnlyNewItems(items: [wrapDataValue])
                    }
                    
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
