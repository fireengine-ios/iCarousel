//
//  UploadService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

enum URLs {
    static let uploadContainer = RouteRequests.BaseUrl +/ "/api/container/baseUrl"
}

final class UploadQueueService {
    let queue = OperationQueue()
    
    func add(_ operationsons: [Operation], progressHandler: @escaping Request.ProgressHandler, complition: @escaping ResponseVoid) {
        let operation = UploadOperation(url: URL(string: "")!, progressHandler: progressHandler) { (result) in
            switch result {
            case .success(_):
                break
            case .failed(let error):
                self.queue.cancelAllOperations()
                break
            }
        }
        operation.completionBlock = {
            
        }
        queue.addOperation(operation)
        
        queue.waitUntilAllOperationsAreFinished()
        complition(ResponseResult.success(()))
    }
}

final class UploadOperation: AsyncOperation {
    
    lazy var uploadService = UploadService()
    
    let url: URL
    let progressHandler: Request.ProgressHandler
    let complition: ResponseVoid
    var dataRequest: DataRequest?
    
    init(url: URL, progressHandler: @escaping Request.ProgressHandler, complition: @escaping ResponseVoid) {
        self.url = url
        self.progressHandler = progressHandler
        self.complition = complition
        super.init()
    }
    
    override func main() {
        dataRequest = uploadService.upload(url: url, progressHandler: progressHandler, complition: { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.animateDismiss()
//            case .failed(let error):
//                self?.progressLabel.text = error.localizedDescription
//            }
            self?.complition(result)
            self?.finish()
        })
    }
    
    override func cancel() {
        dataRequest?.cancel()
        finish()
    }
}

final class UploadService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
    }
    
    func getBaseUploadUrl(handler: @escaping ResponseHandler<String>) {
        sessionManager
            .request(URLs.uploadContainer)
            .customValidate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: String], let path = json["value"] {
                        handler(ResponseResult.success(path))
                    } else {
                        let error = CustomErrors.text("Server error \(json)")
                        handler(ResponseResult.failed(error))
                    }
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
    
    @discardableResult
    func upload(url: URL, progressHandler: @escaping Request.ProgressHandler, complition: @escaping ResponseVoid) -> DataRequest? {
        
        var dataRequest: DataRequest?
        let semaphore = DispatchSemaphore(value: 0)
        
        getBaseUploadUrl { result in
            switch result {
            case .success(let path):
                guard let serverUrl = URL(string: path) else {
                    return
                }
                let uploadUrl = serverUrl +/ UUID().uuidString
                
                let headers: HTTPHeaders = [
                    HeaderConstant.XObjectMetaFavorites: "false",
                    HeaderConstant.XMetaStrategy: "1",
                    HeaderConstant.Expect: "100-continue",
                    HeaderConstant.XObjectMetaParentUuid: "",
                    HeaderConstant.XObjectMetaFileName: url.lastPathComponent,
                    HeaderConstant.ContentType: url.imageContentType,
                    HeaderConstant.XObjectMetaSpecialFolder: "MOBILE_UPLOAD"
                ]
                
                dataRequest = self.sessionManager
                    .upload(url, to: uploadUrl, method: .put, headers: headers)
                    .customValidate()
                    .uploadProgress(closure: progressHandler)
                    .responseString { response in
                        switch response.result {
                        case .success(_):
                            complition(ResponseResult.success(()))
                        case .failure(let error):
                            //if
                            self.upload(url: url, progressHandler: progressHandler, complition: complition)
                            complition(ResponseResult.failed(error))
                        }
                }
                semaphore.signal()
                
            case .failed(let error):
                complition(ResponseResult.failed(error))
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return dataRequest
    }
}
