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
    private var uploadOnDemandOperations = [UploadOperations]()
    
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
    
    
    // MARK: - Upload on demand
    
    func uploadOnDemandFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String) {
            WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: items.count, completedOperations: 0)
            let allOperationCount = items.count
            var completedOperationCount = 0
            let operations: [UploadOperations] = items.flatMap {
                UploadOperations(item: $0, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, success: {
                    completedOperationCount = completedOperationCount + 1
                    WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload, allOperations: allOperationCount, completedOperations: completedOperationCount)
                }, fail: { (error) in
                    completedOperationCount = completedOperationCount + 1
                    //TODO: Error alert
                })
            }
            uploadOnDemandOperations.append(contentsOf: operations)
    }
    
    func uploadOnDemand(success: FileOperationSucces?, fail: FailResponse?) {
        guard !self.uploadOnDemandOperations.isEmpty else {
            return
        }
        
        dispatchQueue.async {
            self.uploadQueue.addOperations(self.uploadOnDemandOperations, waitUntilFinished: true)
            self.uploadOnDemandOperations.removeAll()
            success?()
            WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
        }
    }
    
    //MARK: -
    
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse? ) {

        WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: items.count, completedOperations: 0)
        let allOperationCount = items.count
        var completedOperationCount = 0
        let operations: [UploadOperations] = items.flatMap {
            UploadOperations(item: $0, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, success: {
                completedOperationCount = completedOperationCount + 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload, allOperations: allOperationCount, completedOperations: completedOperationCount)
            }, fail: { (error) in
                completedOperationCount = completedOperationCount + 1
                //WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload, allOperations: allOperationCount, completedOperations: completedOperationCount)
            })
        }
        uploadOperations.append(contentsOf: operations)
        
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: true)
            success?()
            WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
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

private class UploadOperations: Operation {
    
    let item: WrapData
    let uploadType: UploadType
    let uploadStategy: MetaStrategy
    let uploadTo: MetaSpesialFolder
    let folder: String
    let success: FileOperationSucces?
    let fail: FailResponse?
    var requestObject: URLSessionUploadTask?
    var isRealCancel = false
    
    private let semaphore: DispatchSemaphore
    
    init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse?) {
        
        self.item = item
        self.uploadType = uploadType
        self.uploadTo = uploadTo
        self.uploadStategy = uploadStategy
        self.folder = folder
        self.success = success
        self.fail = fail
        self.semaphore = DispatchSemaphore(value: 0)
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
            self.success?()
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
                                      uploadType: self.uploadType,
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
                        let wrapDataValue = WrapData(remote: uploadedFileDetail)
                        CoreDataStack.default.appendOnlyNewItems(items: [wrapDataValue])
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
