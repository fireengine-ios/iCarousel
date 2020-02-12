//
//  BaseRequestService.swift
//  Depo
//
//  Created by Alexander Gurin on 7/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol ObjectFromRequestResponse: class {
    
    init(json: Data?, headerResponse: HTTPURLResponse?)
        
    func mapping()
}

protocol RequestParametrs {
    
    var timeout: TimeInterval { get }
    
    var requestParametrs: Any { get }
    
    var patch: URL { get }
    
    var header: RequestHeaderParametrs { get }
}

protocol UploadRequestParametrs: RequestParametrs {
    var urlToLocalFile: URL? { get }
    var fileData: Data? { get }
    var uploadType: UploadType? { get }
}

protocol DownloadRequestParametrs: RequestParametrs {
    var urlToRemoteFile: URL { get }
}

class BaseDownloadRequestParametrs: DownloadRequestParametrs {
    let urlToRemoteFile: URL
    
    let contentType: FileType
    
    let fileName: String
    
    let albumName: String?
    
    let item: WrapData?
    
    var requestParametrs: Any {
        return Data()
    }
    
    var patch: URL {
        return urlToRemoteFile
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
    
    init(urlToFile: URL, fileName: String, contentType: FileType, albumName: String? = nil, item: WrapData? = nil) {
        urlToRemoteFile = urlToFile
        self.contentType = contentType
        self.fileName = fileName
        self.albumName = albumName
        self.item = item
    }
}

class BaseRequestParametrs: RequestParametrs {
    
    var requestParametrs: Any {
        return Data()
    }
    
    var patch: URL {
        return RouteRequests.baseUrl
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
    
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
}

class JsonConvertor {
    private let value: RequestParametrs
    
    init(parametrs: RequestParametrs) {
        value = parametrs
    }
    
    func convertToData() -> Data? {
        var jsonData: Data? = nil
        
        if let data = value.requestParametrs as? Data {
            jsonData = data
        } else if let str = value.requestParametrs as? String {
            jsonData = str.data(using: .utf8)
        } else if let data = try? JSONSerialization.data(withJSONObject: value.requestParametrs,
                                                 options: .prettyPrinted) {
            jsonData = data
        }
        if let data = jsonData, let str = String(data: data, encoding: .utf8) {
            debugPrint("JSON:", str)
        }
        return jsonData
    }
}

class BaseRequestService: TransIdLogging {
    
    let requestService = RequestService.default
    let transIdLogging: Bool
    
    init(transIdLogging: Bool = false) {
        self.transIdLogging = transIdLogging
    }
    
    func executePostRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method: RequestMethod.Post,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    @discardableResult
    func executeGetRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>)  -> URLSessionTask {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: nil,
                                                      method: RequestMethod.Get,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
        
        return task
    }
    
    func executeDeleteRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method: RequestMethod.Delete,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executePutRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method: RequestMethod.Put,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executePatchRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>) {
        let task = requestService.requestTask(patch: param.patch,
                                              headerParametrs: param.header,
                                              body: JsonConvertor(parametrs: param).convertToData(),
                                              method: RequestMethod.Patch,
                                              timeoutInterval: param.timeout,
                                              response: handler.response)
        task.resume()
    }
    
    func executeDownloadRequest(param: DownloadRequestParametrs, response:@escaping RequestFileDownloadResponse) {
        let task = requestService.downloadFileRequestTask(patch: param.patch,
                                                           headerParametrs: param.header,
                                                           body: nil,
                                                           method: RequestMethod.Get,
                                                           timeoutInterval: param.timeout,
                                                           response: response)
        task.resume()
    }
    
    func executeUploadRequest(param: UploadRequestParametrs, response:@escaping RequestFileUploadResponse) -> URLSessionTask? {
        var task: URLSessionTask?

        if let localURL = param.urlToLocalFile {
            task = requestService.uploadFileRequestTask(patch: param.patch,
                                                            headerParametrs: param.header,
                                                            fromFile: localURL,
                                                            method: RequestMethod.Put,
                                                            timeoutInterval: param.timeout,
                                                            response: response)
        } else if let fileData = param.fileData {
            task = requestService.uploadFileRequestTask(path: param.patch,
                                                        headerParametrs: param.header,
                                                        fileData: fileData,
                                                        method: RequestMethod.Put,
                                                        timeoutInterval: param.timeout,
                                                        response: response)
        } else {
            debugPrint("Upload: wrong parameters", param)
            return nil
        }
        
        task?.resume()
        
        return task
    }
    
    func executeHeadRequest<T, P> (param: RequestParametrs, handler: BaseResponseHandler<T, P>) {
        let task = requestService.headRequestTask(patch: param.patch,
                                                  headerParametrs: param.header,
                                                  method: RequestMethod.Head,
                                                  timeoutInterval: param.timeout,
                                                  response: handler.response)
        task.resume()
    }
}

protocol TransIdLogging: class {
    var transIdLogging: Bool { get }
    func debugLogTransIdIfNeeded(headers: [AnyHashable: Any]?, method: String)
    func debugLogTransIdIfNeeded(errorResponse: ErrorResponse, method: String)
}

extension TransIdLogging {
    func debugLogTransIdIfNeeded(headers: [AnyHashable: Any]?, method: String) {
        if transIdLogging,
            let headers = headers,
            let transId = headers[HeaderConstant.transId] {
            let serviceName = String(describing: type(of: self))
            debugLog("\(serviceName) \(method) \(HeaderConstant.transId): \(transId)")
        }
    }
    
    func debugLogTransIdIfNeeded(errorResponse: ErrorResponse, method: String) {
        if case ErrorResponse.failResponse(let response) = errorResponse {
            debugLogTransIdIfNeeded(headers: (response as? ObjectRequestResponse)?.response?.allHeaderFields, method: method)
        }
    }
}
