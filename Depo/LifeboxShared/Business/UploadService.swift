//
//  UploadService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

typealias DataRequestHandler = (DataRequest) -> Void

final class UploadService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
    }
    
    func getBaseUploadUrl(handler: @escaping ResponseHandler<String>) -> DataRequest {
        return sessionManager
            .request(RouteRequests.uploadContainer)
            .customValidate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: String], let path = json["value"] {
                        handler(ResponseResult.success(path))
                    } else {
                        let error = CustomErrors.text("Server error: \(json)")
                        handler(ResponseResult.failed(error))
                    }
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
    
    private func waitFilePreparation(at url: URL, complition: ResponseVoid) {
        var fcError: NSError?
        let fileCoordinator = NSFileCoordinator()
        
        fileCoordinator.coordinate(readingItemAt: url, options: .forUploading, error: &fcError) { (readUrl) in
            if let error = fcError {
                complition(ResponseResult.failed(error))
            } else {
                complition(ResponseResult.success(()))
            }
        }
    }
    
    
//    do {
//    try waitFilePreparation(at: url)
//    } catch  {
//    complition(ResponseResult.failed(error))
//    return
//    }
    private func waitFilePreparation(at url: URL) throws {
        var fcError: NSError?
        let fileCoordinator = NSFileCoordinator()
        let semaphore = DispatchSemaphore(value: 0)
        
        fileCoordinator.coordinate(readingItemAt: url, options: .forUploading, error: &fcError) { (readUrl) in
            semaphore.signal()
        }
        semaphore.wait()
        
        if let error = fcError {
            throw error
        }
    }
    
    func upload(url: URL, contentType: String, progressHandler: @escaping Request.ProgressHandler, dataRequestHandler: DataRequestHandler?, complition: @escaping ResponseVoid) {
        
        waitFilePreparation(at: url) { [weak self] result in
            switch result {
            case .success(_):
                
                let dataRequest = getBaseUploadUrl { [weak self] result in
                    switch result {
                    case .success(let path):
                        
                        guard let `self` = self else {
                            return
                        }
                        
                        let uploadUrl = path + "/" + UUID().uuidString
                        
                        let headers: HTTPHeaders = [
                            HeaderConstant.XObjectMetaFavorites: "false",
                            HeaderConstant.XMetaStrategy: "1",
                            HeaderConstant.Expect: "100-continue",
                            HeaderConstant.XObjectMetaParentUuid: "",
                            HeaderConstant.XObjectMetaFileName: url.lastPathComponent,
                            HeaderConstant.ContentType: contentType,
                            HeaderConstant.XObjectMetaSpecialFolder: "MOBILE_UPLOAD"
                        ]
                        
                        let dataRequest = self.sessionManager
                            .upload(url, to: uploadUrl, method: .put, headers: headers)
                            .customValidate()
                            .uploadProgress(closure: progressHandler)
                            .responseString { response in
                                switch response.result {
                                case .success(_):
                                    complition(ResponseResult.success(()))
                                case .failure(let error):
                                    complition(ResponseResult.failed(error))
                                }
                        }
                        dataRequestHandler?(dataRequest)
                    case .failed(let error):
                        complition(ResponseResult.failed(error))
                    }
                }
                dataRequestHandler?(dataRequest)
                
            case .failed(let error):
                complition(ResponseResult.failed(error))
            }
        }
    }
}
