//
//  RequestService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

typealias RequestHeaderParametrs = [String:String]
typealias RequestResponse = (Data?, URLResponse?, Error?) -> Swift.Void
typealias RequestFileDownloadResponse = (URL?, URLResponse?, Error?) -> Swift.Void
typealias RequestFileUploadResponse =  (Data?, URLResponse?, Error?) -> Swift.Void

enum RequestMethod: String {
    case Post   = "POST"
    case Get    = "GET"
    case Delete = "DELETE"
    case Put    = "PUT"
    case Head    = "HEAD"
}

import Alamofire
class RequestService {
    
    static let `default` = RequestService()
    
    private var uploadProgressService = UploadProgressService.shared
    
    public func downloadRequestTask(patch:URL,
                                headerParametrs: RequestHeaderParametrs,
                                body: Data?,
                                method: RequestMethod,
                                timeoutInterval: TimeInterval,
                                response: @escaping RequestResponse ) -> URLSessionTask {
        log.debug("RequestService downloadRequestTask")
        
        var request = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.request(request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    public func uploadRequestTask(patch:URL,
                              headerParametrs: RequestHeaderParametrs,
                              body: Data?,
                              method: RequestMethod,
                              timeoutInterval: TimeInterval,
                              response: @escaping RequestResponse ) -> URLSessionTask {
        log.debug("RequestService uploadRequestTask")
        
        var request: URLRequest = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
        let sessionRequest = SessionManager.default.upload(body!, with: request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    
    public func downloadFileRequestTask(patch:URL,
                                    headerParametrs: RequestHeaderParametrs,
                                    body: Data?,
                                    method: RequestMethod,
                                    timeoutInterval: TimeInterval,
                                    response: @escaping RequestFileDownloadResponse ) -> URLSessionTask {
        log.debug("RequestService downloadFileRequestTask")
        
        
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.download(request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.temporaryURL, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    public func uploadFileRequestTask(patch:URL,
                                  headerParametrs: RequestHeaderParametrs,
                                  fromFile: URL,
                                  method: RequestMethod,
                                  timeoutInterval: TimeInterval,
                                  response: @escaping RequestFileUploadResponse ) -> URLSessionTask {
        log.debug("RequestService uploadFileRequestTask")
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.upload(fromFile, with: request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    public func uploadFileRequestTask(path:URL,
                                      headerParametrs: RequestHeaderParametrs,
                                      fileData: Data,
                                      method: RequestMethod,
                                      timeoutInterval: TimeInterval,
                                      response: @escaping RequestFileUploadResponse ) -> URLSessionTask {
        log.debug("RequestService uploadFileRequestTask")
        
        var request: URLRequest = URLRequest(url: path)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.upload(fileData, with: request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    public func headRequestTask(patch:URL,
                                    headerParametrs: RequestHeaderParametrs,
                                    method: RequestMethod,
                                    timeoutInterval: TimeInterval,
                                    response: @escaping RequestResponse ) -> URLSessionTask {
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        request.cachePolicy = .reloadRevalidatingCacheData
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.request(request)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
}
