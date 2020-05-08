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
    
    private let excludedKeys = ["otpcode", "token"]
    
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
                self.canLogRequest(requestURL, httpMethod: httpMethod)
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
                let httpMethod = request.httpMethod,
                let requestURL = request.url,
                self.canLogRequest(requestURL, httpMethod: httpMethod)
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
                    let json = JSON(data: data)
                    let string = try? self.filteredRawString(from: json) ?? ""
                    self.log(body: string ?? "")
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
    
    private func canLogRequest(_ url: URL, httpMethod: String) -> Bool {
        // ReachabilityService.checkAPI
        if url == RouteRequests.baseUrl {
            return false
        }
        
        // Download images for display in cells|views
        if httpMethod == "GET", url.absoluteString.uppercased().contains("CONTAINER_EXTENDED") {
            return false
        }
        
        return true
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
    
    private func filteredRawString(from json: JSON, maxObjectDepth: Int = 10) throws -> String? {
        switch json.type {
        case .dictionary:
            do {
                guard let dict = json.object as? [String: Any?] else {
                    return nil
                }
                let body = try dict.keys.compactMap { key throws -> String? in
                    let isExcludedKey = excludedKeys.first(where: { key.lowercased().contains($0) }) != nil
                    guard !isExcludedKey else {
                        return nil
                    }
                    
                    guard let value = dict[key] else {
                        return "\"\(key)\": null"
                    }
                    guard let unwrappedValue = value else {
                        return "\"\(key)\": null"
                    }

                    let nestedValue = JSON(unwrappedValue)
                    guard let nestedString = try filteredRawString(from: nestedValue, maxObjectDepth: maxObjectDepth - 1) else {
                        throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey: "Could not serialize nested JSON"])
                    }
                    if nestedValue.type == .string {
                        return "\"\(key)\": \"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                    } else {
                        return "\"\(key)\": \(nestedString)"
                    }
                }

                return "{\(body.joined(separator: ","))}"
            } catch _ {
                return nil
            }
        case .array:
            do {
                guard let array = json.object as? [Any?] else {
                    return nil
                }
                let body = try array.map { value throws -> String in
                    guard let unwrappedValue = value else {
                        return "nil"
                    }

                    let nestedValue = JSON(unwrappedValue)
                    guard let nestedString = try filteredRawString(from: nestedValue, maxObjectDepth: maxObjectDepth - 1) else {
                        throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey: "Could not serialize nested JSON"])
                    }
                    if nestedValue.type == .string {
                        return "\"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                    } else {
                        return nestedString
                    }
                }

                return "[\(body.joined(separator: ","))]"
            } catch _ {
                return nil
            }
        default:
            return json.rawString()
        }
    }
}
