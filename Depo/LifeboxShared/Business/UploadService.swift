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

typealias HandlerDataRequest = (DataRequest) -> Void

final class UploadService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
    }
    
    func getBaseUploadUrl(handler: @escaping ResponseHandler<String>) -> DataRequest {
        return sessionManager
            .request(URLs.uploadContainer)
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
    
    func upload(url: URL, contentType: String, progressHandler: @escaping Request.ProgressHandler, handlerDataRequest: HandlerDataRequest?, complition: @escaping ResponseVoid) {
        
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
                handlerDataRequest?(dataRequest)
            case .failed(let error):
                complition(ResponseResult.failed(error))
            }
        }
        handlerDataRequest?(dataRequest)
    }
}
