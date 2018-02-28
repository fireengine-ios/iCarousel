//
//  ClearUploadService.swift
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

final class ClearUploadService {
    
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
    
    func upload(url: URL, progressHandler: @escaping Request.ProgressHandler, complition: @escaping ResponseVoid) {
        
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
                
                self.sessionManager
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
                
            case .failed(let error):
                complition(ResponseResult.failed(error))
            }
        }
        
        
    }
}
