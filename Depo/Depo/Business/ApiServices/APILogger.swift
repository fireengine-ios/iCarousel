//
//  APILogger.swift
//  Depo
//
//  Created by Andrei Novikau on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

final class APILogger {
    
    static let shared = APILogger()
    
    private let queue = DispatchQueue(label: "\(APILogger.self) Queue")
    
    private lazy var userDefaults: StorageVars = factory.resolve()
    
    private var startDates = [URLSessionTask: Date]()
    
    // set true for logging to console
    private let isDebugLog = false
    
    deinit {
        stopLogging()
    }
    
    func startLogging() {
        stopLogging()
        
        let notificationCenter = NotificationCenter.default
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requestDidStart(notification:)),
                                               name: Notification.Name.Task.DidResume,
                                               object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(requestDidFinish(notification:)),
                                       name: Notification.Name.Task.DidComplete,
                                       object: nil)
    }
    
    func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func requestDidStart(notification: Notification) {
        queue.async { [weak self] in
            guard let self = self,
                let userInfo = notification.userInfo,
                let task = userInfo[Notification.Key.Task] as? URLSessionTask,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url,
                requestURL != RouteRequests.baseUrl // ReachabilityService.checkAPI
                else {
                    return
            }
            
            self.startDates[task] = Date()
            self.log(string: "--> \(httpMethod) \(requestURL.absoluteString)")
            
            if requestURL.absoluteString.contains("upload-type=resumable") {
                self.logResumableUpload(headers: request.allHTTPHeaderFields)
            }
        }
    }
    
    @objc private func requestDidFinish(notification: Notification) {
        queue.async { [weak self] in
            guard let self = self,
                let userInfo = notification.userInfo,
                let task = userInfo[Notification.Key.Task] as? URLSessionTask,
                let request = task.originalRequest,
                let requestURL = request.url,
                requestURL != RouteRequests.baseUrl // ReachabilityService.checkAPI
                else {
                    return
            }
            
            var elapsedTime: TimeInterval = 0.0
            
            if let startDate = self.startDates[task] {
                elapsedTime = Date().timeIntervalSince(startDate)
                self.startDates[task] = nil
            }
         
            let data = userInfo[Notification.Key.ResponseData] as? Data
            
            if let response = task.response as? HTTPURLResponse {
                let transId = response.allHeaderFields[HeaderConstant.transId] as? String
                self.log(statusCode: response.statusCode,
                         url: requestURL,
                         elapsedTime: elapsedTime,
                         dataLength: data?.count,
                         transId: transId)
                
                if 200...299 ~= response.statusCode {
                    if let error = task.error as? URLError, error.code == .networkConnectionLost {
                        self.log(string: "The network connection was lost")
                    }
                } else if let data = data {
                    let jsonString = JSON(data: data).stringValue
                    self.log(body: jsonString)
                } else if let error = task.error {
                    self.log(body: error.localizedDescription)
                }
            } else if let error = task.error {
                self.log(statusCode: nil,
                         url: requestURL,
                         elapsedTime: elapsedTime,
                         dataLength: data?.count,
                         transId: nil)
                
                self.log(body: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Logging
    
    private func log(statusCode: Int?, url: URL, elapsedTime: TimeInterval, dataLength: Int?, transId: String?) {
        var string = "<-- "
        if let statusCode = statusCode {
            string += "\(statusCode) "
        }
        
        string += "\(url.absoluteString) "
        
        let timeString = String(format: "%.0f ms", elapsedTime * 1000)
        if let dataLength = dataLength {
            string += "(\(timeString), \(dataLength) bytes)"
        } else {
            string += "(\(timeString), unknown-length body)"
        }
    
        if let transId = transId {
            string += " \(HeaderConstant.transId): \(transId)"
        }
        log(string: string)
    }
    
    private func log(body: String) {
        guard !body.isEmpty else {
            return
        }
        log(string: "BODY:")
        log(string: body)
    }
    
    private func logResumableUpload(headers: HTTPHeaders?) {
        guard let headers = headers,
            let fileName = headers[HeaderConstant.XObjectMetaFileName],
            let length = headers[HeaderConstant.ContentLength],
            let range = headers[HeaderConstant.ContentRange]
            else {
                assertionFailure()
            return
        }
        
        log(string: "[Resumable upload]")
        log(string: "Filename: \(fileName)")
        log(string: "\(HeaderConstant.ContentRange): \(range)")
        log(string: "\(HeaderConstant.ContentLength): \(length)")
        
        if let chunkSize = userDefaults.resumableUploadChunkSize {
            log(string: "Current Chunk Size: \(chunkSize)")
        }
    }
    
    private func log(string: String) {
        if isDebugLog {
            printLog(string)
        } else {
            debugLog(string)
        }
    }
}


