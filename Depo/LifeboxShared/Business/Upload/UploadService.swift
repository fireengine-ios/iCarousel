//
//  UploadService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias DataRequestHandler = (DataRequest) -> Void
typealias ResumableUploadHandler = ResponseHandler<ResumableUploadStatus>

enum ResumableUploadStatus {
    case uploaded(bytes: Int)
    case didntStart
    case invalidUploadRequest
    case discontinuityError
    case completed
}


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
        
        guard
            let fileSize = FileManager.default.fileSize(at: url),
            fileSize < NumericConstants.fourGigabytes
            else {
                let error = CustomErrors.text(TextConstants.syncFourGbVideo)
                completion(ResponseResult.failed(error))
                return
        }
        
        guard fileSize > 0 else {
            assertionFailure(TextConstants.syncZeroBytes)
            let error = CustomErrors.text(TextConstants.syncZeroBytes)
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
    }
    
    func upload(data: Data,
                name: String,
                contentType: String,
                progressHandler: @escaping Request.ProgressHandler,
                dataRequestHandler: DataRequestHandler?,
                completion: @escaping ResponseVoid)
    {
        let fileSize = Int64(data.count)
        
        guard fileSize < NumericConstants.fourGigabytes else {
            let error = CustomErrors.text(TextConstants.syncFourGbVideo)
            completion(ResponseResult.failed(error))
            return
        }
        
        guard fileSize > 0 else {
            assertionFailure(TextConstants.syncZeroBytes)
            let error = CustomErrors.text(TextConstants.syncZeroBytes)
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
    
    private func resumableUploadResponse(for response: DataResponse<String>, completion: @escaping ResumableUploadHandler) {
        switch response.result {
        case .success(_):
            completion(.success(.completed))
            
        case .failure(let error):
            guard let statusCode = response.response?.statusCode else {
                completion(.failed(error))
                return
            }
            
            switch statusCode {
            case 308:
                guard
                    let headerValue = response.response?.allHeaderFields["Range"] as? String,
                    let upperValueString = headerValue.lastNonEmptyHalf(after: "-"),
                    let upperValue = Int(upperValueString)
                else {
                    completion(.failed(error))
                    return
                }
                
                completion(.success(.uploaded(bytes: upperValue + 1)))
                
            case 400:
                
                if let data = response.data {
                    let json = JSON(data: data)
                    let errorCode = json["error_code"].stringValue
                    
                    switch errorCode {
                    case "RU_9":
                        /// Provided first-byte-pos is not the continuation of the last-byte-pos of pre-uploaded part!
                        completion(.success(.discontinuityError))
                        
                    case "RU_1":
                        /// Invalid upload request! Initial upload must start from the beginning
                        completion(.success(.invalidUploadRequest))
                        
                    default:
                        completion(.failed(error))
                    }
                } else {
                    completion(.failed(error))
                }
                
            case 404:
                completion(.success(.didntStart))
                
            default:
                completion(.failed(error))
            }
        }
    }
    
    func checkResumableUploadStatus(interruptedId: String,
                                    name: String,
                                    contentType: String,
                                    dataRequestHandler: DataRequestHandler?,
                                    completion: @escaping ResumableUploadHandler) {
        let dataRequest = getBaseUploadUrl { [weak self] result in
            switch result {
            case .success(let baseUploadUrl):
                guard let self = self else {
                    return
                }
                
                let headers = self.commonHeaders(name: name, contentType: contentType, fileSize: 0)
                let uploadUrl = baseUploadUrl + "/" + interruptedId
                
                let dataRequest = self.sessionManager
                    .upload(Data(), to: uploadUrl, method: .put, headers: headers)
                    .customValidate()
                    .responseString { [weak self] response in
                        self?.resumableUploadResponse(for: response, completion: completion)
                }
                dataRequestHandler?(dataRequest)
                
            case .failed(let error):
                completion(ResponseResult.failed(error))
            }
        }
        dataRequestHandler?(dataRequest)
    }
    
    
    func resumableUpload(interruptedId: String, data: Data, range: Range<Int>,
                         name: String, contentType: String, fileSize: Int64,
                         dataRequestHandler: DataRequestHandler?,
                         progressHandler: @escaping Request.ProgressHandler,
                         completion: @escaping ResumableUploadHandler) {
        let dataRequest = getBaseUploadUrl { [weak self] result in
            switch result {
            case .success(let baseUploadUrl):
                guard let self = self else {
                    return
                }
                
                let headers = self.resumableUploadHeaders(name: name, contentType: contentType, fileSize: fileSize, range: range)
                let uploadUrl = baseUploadUrl + "/" + interruptedId
                
                let dataRequest = self.sessionManager
                    .upload(data, to: uploadUrl, method: .put, headers: headers)
                    .customValidate()
                    .uploadProgress(closure: progressHandler)
                    .responseString { [weak self] response in
                        self?.resumableUploadResponse(for: response, completion: completion)
                }
                dataRequestHandler?(dataRequest)
                
            case .failed(let error):
                completion(ResponseResult.failed(error))
            }
        }
        dataRequestHandler?(dataRequest)
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
    
    private func resumableUploadHeaders(name: String, contentType: String, fileSize: Int64, range: Range<Int>) -> HTTPHeaders {
        let contentRangeValue = "bytes \(range.lowerBound)-\(range.upperBound - 1)/\(fileSize)"
        let simpleHeaders = commonHeaders(name: name, contentType: contentType, fileSize: fileSize)
        
        return simpleHeaders + [HeaderConstant.ContentRange : contentRangeValue]
    }
    
}


private extension String {
    func lastNonEmptyHalf(after separator: Character) -> String? {
        guard
            let substring = self.split(separator: separator, maxSplits: 2, omittingEmptySubsequences: true).last
        else {
            return nil
        }
        
        return String(substring)
    }
}
