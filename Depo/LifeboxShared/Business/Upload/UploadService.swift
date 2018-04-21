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
    
    func upload(url: URL, contentType: String, progressHandler: @escaping Request.ProgressHandler, dataRequestHandler: DataRequestHandler?, completion: @escaping ResponseVoid) {
        
        FilesExistManager.shared.waitFilePreparation(at: url) { [weak self] result in
            switch result {
            case .success(_):
                
                guard
                    let fileSize = FileManager.default.fileSize(at: url),
                    fileSize < NumericConstants.fourGigabytes
                else {
                    let error = CustomErrors.text(TextConstants.syncFourGbVideo)
                    completion(ResponseResult.failed(error))
                    return
                }
                
                let dataRequest = getBaseUploadUrl { [weak self] result in
                    switch result {
                    case .success(let baseUploadUrl):
                        
                        guard let `self` = self else {
                            return
                        }
                        
                        let uploadUrl = baseUploadUrl + "/" + UUID().uuidString
                        
                        let headers: HTTPHeaders = [
                            HeaderConstant.XObjectMetaFavorites: "false",
                            HeaderConstant.XMetaStrategy: MetaStrategy.WithoutConflictControl.rawValue,
                            HeaderConstant.Expect: "100-continue",
                            HeaderConstant.XObjectMetaParentUuid: "",
                            HeaderConstant.XObjectMetaFileName: url.lastPathComponent,
                            HeaderConstant.ContentType: contentType,
                            HeaderConstant.XObjectMetaSpecialFolder: MetaSpesialFolder.MOBILE_UPLOAD.rawValue,
                            HeaderConstant.ContentLength: String(fileSize),
                            HeaderConstant.XObjectMetaDeviceType: Device.deviceType
                        ]
                        
                        let dataRequest = self.sessionManager
                            .upload(url, to: uploadUrl, method: .put, headers: headers)
                            .customValidate()
                            .uploadProgress(closure: progressHandler)
                            .responseString { response in
                                switch response.result {
                                case .success(_):
                                    completion(ResponseResult.success(()))
                                case .failure(let error):
                                    completion(ResponseResult.failed(error))
                                }
                        }
                        dataRequestHandler?(dataRequest)
                    case .failed(let error):
                        completion(ResponseResult.failed(error))
                    }
                }
                dataRequestHandler?(dataRequest)
                
            case .failed(let error):
                completion(ResponseResult.failed(error))
            }
        }
    }
}


extension FileManager {
    func fileSize(at url: URL) -> Int64? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[FileAttributeKey.size] as? Int64
    }
}
