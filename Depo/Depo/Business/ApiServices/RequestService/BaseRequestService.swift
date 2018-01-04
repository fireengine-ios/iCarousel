//
//  BaseRequestService.swift
//  Depo
//
//  Created by Alexander Gurin on 7/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol ObjectFromRequestResponse: class {
    
    init(json:Data?, headerResponse:HTTPURLResponse?)
        
    func mapping()
}

protocol RequestParametrs {
    
    var requestParametrs: Any { get }
    
    var patch: URL {get}
    
    var header: RequestHeaderParametrs { get }
}

protocol UploadRequestParametrs: RequestParametrs {
    var urlToLocalFile: URL { get }
}

protocol UploadDataRequestParametrs: RequestParametrs {
    var data: Data { get }
}

protocol DownloadRequestParametrs: RequestParametrs {
    
    var urlToRemoteFile: URL {get}
}

class BaseUploadRequestParametrs: UploadRequestParametrs {
    
    var urlToLocalFile: URL

    
    var requestParametrs: Any {
        return Data()
    }
    
    var patch: URL {
        return RouteRequests.BaseUrl
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
    
    init(urlToFile: URL) {
        urlToLocalFile = urlToFile
    }
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
    
    init(urlToFile: URL, fileName: String, contentType: FileType, albumName: String? = nil, item: WrapData? = nil) {
        urlToRemoteFile = urlToFile
        self.contentType = contentType
        self.fileName = fileName
        self.albumName = albumName
        self.item = item
    }
}

class DownloadFileResponse: ObjectRequestResponse {
    
    var eTag: String?
    var lenghth: Int64?
    
    override func mapping() {
//        eTag = response?["Etag"]
//        lenghth = response?["Content-Length"]
    }
}


class BaseRequestParametrs: RequestParametrs {
    
    var requestParametrs: Any {
        return Data()
    }
    
    var patch: URL {
        return RouteRequests.BaseUrl
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}

class BaseUploadDowbloadRequestParametrs {
    
}


class JsonConvertor {
    private let value: RequestParametrs
    
    init(parametrs: RequestParametrs) {
        value = parametrs
    }
    
    func convertToData() -> Data? {
        var jsonData: Data? = nil
        
        if let data = value.requestParametrs as? Data  {
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

class BaseRequestService {
    
    let requestService = RequestService.default
    
    func executePostRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.downloadRequestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Post,
                                                      timeoutInterval: 30,
                                                      response: handler.response)
        task.resume()
    }
    
    func executeGetRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        
        let task = requestService.downloadRequestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: nil,
                                                      method:RequestMethod.Get,
                                                      timeoutInterval: 30,
                                                      response: handler.response)
        task.resume()
    }
    
    func executeDeleteRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        
        let task = requestService.downloadRequestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Delete,
                                                      timeoutInterval: 30,
                                                      response: handler.response)
        task.resume()
    }
    
    func executePutRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        
        let task = requestService.downloadRequestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Put,
                                                      timeoutInterval: 30,
                                                      response: handler.response)
        task.resume()
    }
    
    func executeDownloadRequest(param: DownloadRequestParametrs, response:@escaping RequestFileDownloadResponse) {
        
        let task  = requestService.downloadFileRequestTask(patch: param.patch,
                                                           headerParametrs: param.header,
                                                           body: nil,
                                                           method: RequestMethod.Get,
                                                           timeoutInterval: 2000,
                                                           response: response)
        task.resume()
    }
    
    func executeUploadRequest(param: UploadRequestParametrs, response:@escaping RequestFileUploadResponse) -> URLSessionUploadTask {
        let app = UIApplication.shared
        var backgroundTaskID = UIBackgroundTaskInvalid
        backgroundTaskID = app.beginBackgroundTask(withName: param.urlToLocalFile.absoluteString) {
            app.endBackgroundTask(backgroundTaskID)
        }
        let task = requestService.uploadFileRequestTask(patch: param.patch,
                                                        headerParametrs: param.header,
                                                        fromFile: param.urlToLocalFile,
                                                        method: RequestMethod.Put,
                                                        timeoutInterval: 2000,
                                                        response: { (data, urlResponse, error) in
                                                            response(data, urlResponse, error)
                                                            app.endBackgroundTask(backgroundTaskID)
        })
        
        task.resume()
        return task
    }
    
    func executeUploadDataRequest(param: UploadDataRequestParametrs, response:@escaping RequestFileUploadResponse) -> URLSessionUploadTask{
        
        let task = requestService.uploadFileRequestTask(path: param.patch,
                                                        headerParametrs: param.header,
                                                        fileData: param.data,
                                                        method: RequestMethod.Put,
                                                        timeoutInterval: 2000,
                                                        response: response)
        
        task.resume()
        return task
    }
}
