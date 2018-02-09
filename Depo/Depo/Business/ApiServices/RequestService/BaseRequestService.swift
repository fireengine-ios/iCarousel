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
    
    var timeout: TimeInterval { get }
    
    var requestParametrs: Any { get }
    
    var patch: URL {get}
    
    var header: RequestHeaderParametrs { get }
}

protocol UploadRequestParametrs: RequestParametrs {
    var urlToLocalFile: URL? { get }
    var fileData: Data? { get }
}

protocol UploadDataRequestParametrs: RequestParametrs {
    var data: Data { get }
}

protocol DownloadRequestParametrs: RequestParametrs {
    var urlToRemoteFile: URL { get }
}


class BaseUploadRequestParametrs: UploadRequestParametrs {
    
    var urlToLocalFile: URL?

    var fileData: Data?
    
    var requestParametrs: Any {
        return Data()
    }
    
    var patch: URL {
        return RouteRequests.BaseUrl
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
    
    var timeout: TimeInterval{
        return 2000.0
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
    
    var timeout: TimeInterval{
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
    
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
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
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Post,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executeGetRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: nil,
                                                      method:RequestMethod.Get,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executeDeleteRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Delete,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executePutRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.requestTask(patch: param.patch,
                                                      headerParametrs: param.header,
                                                      body: JsonConvertor(parametrs: param).convertToData(),
                                                      method:RequestMethod.Put,
                                                      timeoutInterval: param.timeout,
                                                      response: handler.response)
        task.resume()
    }
    
    func executePatchRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.requestTask(patch: param.patch,
                                              headerParametrs: param.header,
                                              body: JsonConvertor(parametrs: param).convertToData(),
                                              method:RequestMethod.Patch,
                                              timeoutInterval: param.timeout,
                                              response: handler.response)
        task.resume()
    }
    
    func executeDownloadRequest(param: DownloadRequestParametrs, response:@escaping RequestFileDownloadResponse) {
        let task  = requestService.downloadFileRequestTask(patch: param.patch,
                                                           headerParametrs: param.header,
                                                           body: nil,
                                                           method: RequestMethod.Get,
                                                           timeoutInterval: param.timeout,
                                                           response: response)
        task.resume()
    }
    
    func executeUploadRequest(param: UploadRequestParametrs, response:@escaping RequestFileUploadResponse) -> URLSessionTask {
        var backgroundTaskID = UIBackgroundTaskInvalid
        var task = URLSessionTask()

        if let localURL = param.urlToLocalFile {
            backgroundTaskID = beginBackgroundTask(with: localURL.absoluteString)
            
            task = requestService.uploadFileRequestTask(patch: param.patch,
                                                            headerParametrs: param.header,
                                                            fromFile: localURL,
                                                            method: RequestMethod.Put,
                                                            timeoutInterval: param.timeout,
                                                            response: { (data, urlResponse, error) in
                                                                response(data, urlResponse, error)
                                                                UIApplication.shared.endBackgroundTask(backgroundTaskID)
            })
        } else if let fileData = param.fileData {
            let taskName = UUID().uuidString
            backgroundTaskID = beginBackgroundTask(with: taskName)
            
            task = requestService.uploadFileRequestTask(path: param.patch,
                                                        headerParametrs: param.header,
                                                        fileData: fileData,
                                                        method: RequestMethod.Put,
                                                        timeoutInterval: param.timeout,
                                                        response: { (data, urlResponse, error) in
                                                            response(data, urlResponse, error)
                                                            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            })
        } else {
            debugPrint("something went WRONG!! ", param)
        }
        
        task.resume()
        
        return task
    }
    
    func executeHeadRequest<T,P> (param:RequestParametrs, handler:BaseResponseHandler<T,P>) {
        let task = requestService.headRequestTask(patch: param.patch,
                                                  headerParametrs: param.header,
                                                  method: RequestMethod.Head,
                                                  timeoutInterval: param.timeout,
                                                  response: handler.response)
        task.resume()
    }
    
    func executeUploadDataRequest(param: UploadDataRequestParametrs, response:@escaping RequestFileUploadResponse) -> URLSessionTask{

        let task = requestService.uploadFileRequestTask(path: param.patch,
                                                        headerParametrs: param.header,
                                                        fileData: param.data,
                                                        method: RequestMethod.Put,
                                                        timeoutInterval: 2000,
                                                        response: response)
        task.resume()
        return task
    }
    
    //MARK: - Helpers
    
    private func beginBackgroundTask(with name: String?) -> UIBackgroundTaskIdentifier {
        var taskId = UIBackgroundTaskInvalid
        taskId = UIApplication.shared.beginBackgroundTask(withName: name, expirationHandler: {
            UIApplication.shared.endBackgroundTask(taskId)
        })
        return taskId
    }

}
