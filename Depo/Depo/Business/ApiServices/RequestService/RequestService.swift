//
//  RequestService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

typealias RequestResponse = (Data?, URLResponse?, Error?) -> Swift.Void
typealias RequestFileDownloadResponse = (URL?, URLResponse?, Error?) -> Swift.Void
typealias RequestFileUploadResponse =  (Data?, URLResponse?, Error?) -> Swift.Void

enum RequestMethod: String {
    case Post   = "POST"
    case Get    = "GET"
    case Delete = "DELETE"
    case Put    = "PUT"
    case Head    = "HEAD"
    case Patch  = "PATCH"
}

import Alamofire
class RequestService {
    
    static let `default` = RequestService()
    
    public func requestTask(patch: URL,
                            headerParametrs: RequestHeaderParametrs,
                            body: Data?,
                            method: RequestMethod,
                            timeoutInterval: TimeInterval,
                            response: @escaping RequestResponse ) -> URLSessionTask {
        log.debug("RequestService requestTask")
        
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
    
    public func uploadRequestTask(patch: URL,
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
        sessionRequest.uploadProgress { [weak self] progress in
            self?.requestProgressHander(progress, request: request)
        }
        return sessionRequest.task!
    }
    
    
    public func downloadFileRequestTask(patch: URL,
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
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let file = tempDirectoryURL.appendingPathComponent(patch.lastPathComponent, isDirectory: false)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        let sessionRequest = SessionManager.default.download(request, to: destination)
            .customValidate()
            .response { requestResponse in
                response(requestResponse.destinationURL, requestResponse.response, requestResponse.error)
        }
        sessionRequest.downloadProgress { [weak self] progress in
            self?.requestProgressHander(progress, request: request)
        }
        return sessionRequest.task!
    }
    
    public func uploadFileRequestTask(patch: URL,
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
        sessionRequest.uploadProgress { [weak self] progress in
            self?.requestProgressHander(progress, request: request)
        }
        return sessionRequest.task!
    }
    
    public func uploadFileRequestTask(path: URL,
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
        sessionRequest.uploadProgress { [weak self] progress in
            self?.requestProgressHander(progress, request: request)
        }
        return sessionRequest.task!
    }
    
    public func headRequestTask(patch: URL,
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
    
    func requestProgressHander(_ progress: Alamofire.Progress, request: URLRequest) {
        guard let url = request.url
            else { return }
        
        SingletonStorage.shared.progressDelegates.invoke(invocation: { (delegate) in
            delegate.didSend(ratio: Float(progress.fractionCompleted), for: url)
        })
    }
}
