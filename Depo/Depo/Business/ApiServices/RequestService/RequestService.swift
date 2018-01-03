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


class RequestService {
    
    static let `default` = RequestService()
    private let defaultSession: URLSession
    
    private var uploadProgressService = UploadProgressService.shared
    
    
    init() {
        
        let configuration = URLSessionConfiguration.default
        defaultSession = URLSession(configuration: configuration,
                                    delegate: uploadProgressService,
                                    delegateQueue: nil)
    }
    
    public func downloadRequestTask(patch:URL,
                                headerParametrs: RequestHeaderParametrs,
                                body: Data?,
                                method: RequestMethod,
                                timeoutInterval: TimeInterval,
                                response: @escaping RequestResponse ) -> URLSessionDataTask {
        
        var request: URLRequest = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
            request.cachePolicy = NSURLRequest.CachePolicy.reloadRevalidatingCacheData
        
        debugPrint("REQUEST: \(request)")
        
        let task = defaultSession.dataTask(with: request, completionHandler: response)
        return task
    }
    
    public func uploadRequestTask(patch:URL,
                              headerParametrs: RequestHeaderParametrs,
                              body: Data?,
                              method: RequestMethod,
                              timeoutInterval: TimeInterval,
                              response: @escaping RequestResponse ) -> URLSessionUploadTask {
        
        var request: URLRequest = URLRequest(url: patch)
            request.timeoutInterval = timeoutInterval
            request.httpMethod = method.rawValue
            request.httpBody = body
            request.allHTTPHeaderFields = headerParametrs
        
        let task = defaultSession.uploadTask(with: request, from: body, completionHandler: response)
        return task
    }
    
    
    public func downloadFileRequestTask(patch:URL,
                                    headerParametrs: RequestHeaderParametrs,
                                    body: Data?,
                                    method: RequestMethod,
                                    timeoutInterval: TimeInterval,
                                    response: @escaping RequestFileDownloadResponse ) -> URLSessionDownloadTask {
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        let task = defaultSession.downloadTask(with: patch,
                                               completionHandler: response)
        return task
    }
    
    public func uploadFileRequestTask(patch:URL,
                                  headerParametrs: RequestHeaderParametrs,
                                  fromFile: URL,
                                  method: RequestMethod,
                                  timeoutInterval: TimeInterval,
                                  response: @escaping RequestFileUploadResponse ) -> URLSessionUploadTask {
        
        var request: URLRequest = URLRequest(url: patch)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        
        debugPrint("REQUEST: \(request)")
        
        let task = defaultSession.uploadTask(with: request,
                                             fromFile: fromFile,
                                             completionHandler: response)
        
        return task
    }
    
    public func uploadFileRequestTask(path:URL,
                                      headerParametrs: RequestHeaderParametrs,
                                      fileData: Data,
                                      method: RequestMethod,
                                      timeoutInterval: TimeInterval,
                                      response: @escaping RequestFileUploadResponse ) -> URLSessionUploadTask {
        
        var request: URLRequest = URLRequest(url: path)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headerParametrs
        
        debugPrint("REQUEST: \(request)")
        
        return defaultSession.uploadTask(with: request, from: fileData, completionHandler: response)
    }
}
