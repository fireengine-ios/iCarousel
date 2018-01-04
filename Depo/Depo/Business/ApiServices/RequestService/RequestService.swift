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
        
        var request = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.request(request).response { requestResponse in
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
        
        var request: URLRequest = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
        let sessionRequest = SessionManager.default.upload(body!, with: request).response { requestResponse in
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
        
        let sessionRequest = SessionManager.default.download(patch).response { requestResponse in
            response(requestResponse.destinationURL, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
    
    public func uploadFileRequestTask(patch:URL,
                                  headerParametrs: RequestHeaderParametrs,
                                  fromFile: URL,
                                  method: RequestMethod,
                                  timeoutInterval: TimeInterval,
                                  response: @escaping RequestFileUploadResponse ) -> URLSessionTask {
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.upload(fromFile, with: request).response { requestResponse in
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
        
        var request: URLRequest = URLRequest(url: path)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let sessionRequest = SessionManager.default.upload(fileData, with: request).response { requestResponse in
            response(requestResponse.data, requestResponse.response, requestResponse.error)
        }
        return sessionRequest.task!
    }
}
