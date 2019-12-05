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
    
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
    }
    
    private func getBaseUploadUrl(handler: @escaping ResponseHandler<String>) -> DataRequest {
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
    
    func upload(url: URL,
                name: String,
                contentType: String,
                progressHandler: @escaping Request.ProgressHandler,
                dataRequestHandler: DataRequestHandler?,
                completion: @escaping ResponseVoid) {
        
        FilesExistManager.shared.waitFilePreparation(at: url) { [weak self] result in
            switch result {
            case .success(_):
                
                guard
                    let fileSize = FileManager.default.fileSize(at: url),
                    fileSize > 0,
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
                        let headers = self.commonHeaders(name: name, contentType: contentType, fileSize: fileSize)
                        
                        let dataRequest = self.sessionManager
                            .upload(url, to: uploadUrl, method: .put, headers: headers)
                            .customValidate()
                            .uploadProgress(closure: progressHandler)
                            .responseString { [weak self] response in
                                self?.commonUploadResponse(for: response, completion: completion)
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
    
    func upload(data: Data,
                name: String,
                contentType: String,
                progressHandler: @escaping Request.ProgressHandler,
                dataRequestHandler: DataRequestHandler?,
                completion: @escaping ResponseVoid)
    {
        let fileSize = Int64(data.count)
        
        guard fileSize > 0, fileSize < NumericConstants.fourGigabytes else {
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
                let headers = self.commonHeaders(name: name, contentType: contentType, fileSize: fileSize)
                
                let dataRequest = self.sessionManager
                    .upload(data, to: uploadUrl, method: .put, headers: headers)
                    .customValidate()
                    .uploadProgress(closure: progressHandler)
                    .responseString { [weak self] response in
                        self?.commonUploadResponse(for: response, completion: completion)
                }
                dataRequestHandler?(dataRequest)
            case .failed(let error):
                completion(ResponseResult.failed(error))
            }
        }
        dataRequestHandler?(dataRequest)
        
    }
    
    private func commonUploadResponse(for response: DataResponse<String>, completion: @escaping ResponseVoid) {
        switch response.result {
        case .success(_):
            completion(ResponseResult.success(()))
        case .failure(let error):
            if response.response?.statusCode == 413 {
                let errocustomError = CustomErrors.text(TextConstants.lifeboxMemoryLimit)
                completion(ResponseResult.failed(errocustomError))
            } else {
                completion(ResponseResult.failed(error))
            }
        }
    }
    
    private func commonHeaders(name: String, contentType: String, fileSize: Int64) -> HTTPHeaders {
        return [
            HeaderConstant.XObjectMetaFavorites: "false",
            HeaderConstant.XMetaStrategy: MetaStrategy.WithoutConflictControl.rawValue,
            HeaderConstant.Expect: "100-continue",
            HeaderConstant.XObjectMetaParentUuid: "",
            HeaderConstant.XObjectMetaFileName: name,
            HeaderConstant.ContentType: contentType,
            HeaderConstant.XObjectMetaSpecialFolder: MetaSpesialFolder.MOBILE_UPLOAD.rawValue,
            HeaderConstant.ContentLength: String(fileSize),
            HeaderConstant.XObjectMetaDeviceType: Device.deviceType
        ]
    }
    
}
