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
    
    private var startDates = [URLSessionTask: Date]()
    
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
                let requestURL = request.url
                else {
                    return
            }
            
            self.startDates[task] = Date()
            self.log(string: "--> \(httpMethod) \(requestURL.absoluteString)")
        }
    }
    
    @objc private func requestDidFinish(notification: Notification) {
        queue.async { [weak self] in
            guard let self = self,
                let userInfo = notification.userInfo,
                let task = userInfo[Notification.Key.Task] as? URLSessionTask,
                let request = task.originalRequest,
                let requestURL = request.url
                else {
                    return
            }
            
            var elapsedTime: TimeInterval = 0.0
            
            if let startDate = self.startDates[task] {
                elapsedTime = Date().timeIntervalSince(startDate)
                self.startDates[task] = nil
            }
         
            let data = userInfo[Notification.Key.ResponseData] as? Data
            let transId = request.allHTTPHeaderFields?[HeaderConstant.transId]
        
            if let response = task.response as? HTTPURLResponse {
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
                         transId: transId)
                
                self.log(body: error.localizedDescription)
            }
        }
    }
    
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
            string += " \(HeaderConstant.transId) \(transId)"
        }
        log(string: string)
    }
    
    private func log(body: String) {
        log(string: "BODY:")
        log(string: body)
    }
    
    private func log(string: String) {
        if isDebugLog {
            printLog(string)
        } else {
            debugLog(string)
        }
    }
}


