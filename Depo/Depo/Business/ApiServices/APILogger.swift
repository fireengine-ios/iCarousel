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
    private let excludedValues = ["temp_url_sig", "token", "password", "code"]
    
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
                let requestURL = self.filteredUrlString(request.url),
                self.canLogRequest(requestURL, httpMethod: httpMethod)
                else {
                    return
            }
            
            self.startDates[task] = Date()
            
            if let dataLength = request.allHTTPHeaderFields?[HeaderConstant.ContentLength] {
                self.log(string: "--> \(httpMethod) (\(dataLength) bytes) \(requestURL.absoluteString)")
            } else {
                self.log(string: "--> \(httpMethod) \(requestURL.absoluteString)")
            }

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
                let requestURL = self.filteredUrlString(request.url),
                self.canLogRequest(requestURL, httpMethod: httpMethod),
                !(task.state == .canceling && httpMethod == HTTPMethod.get.rawValue)
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
                
                //https://jira.turkcell.com.tr/browse/FE-2558
                //don't need log body if status code 403
                if response.statusCode == 403 {
                    return
                } else if 200...299 ~= response.statusCode {
                    if let error = task.error as? URLError, error.code == .networkConnectionLost {
                        self.log(string: "The network connection was lost")
                    }
                    
                } else if let data = data {
                    let json = JSON(data)
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
        if url == RouteRequests.healthCheck {
            return false
        }
        
        // Download images for display in cells|views
        // CONTAINER_EXTENDED and CONTAINER_MAIN
        if httpMethod == HTTPMethod.get.rawValue, url.absoluteString.uppercased().contains("CONTAINER_") {
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
        log(string: "BODY: \(body)")
    }
    
    private func logResumableUpload(headers: HTTPHeaders?) {
        guard let headers = headers,
            let fileName = headers[HeaderConstant.XObjectMetaFileName],
            let length = headers[HeaderConstant.ContentLength]
            else {
                assertionFailure()
            return
        }
        
        log(string: "[Resumable upload]")
        log(string: "Filename: \(fileName)")
        if let range = headers[HeaderConstant.ContentRange] {
            log(string: "\(HeaderConstant.ContentRange): \(range)")
        }
        log(string: "\(HeaderConstant.ContentLength): \(length)")
        
        if let chunkSize = userDefaults.resumableUploadChunkSize {
            log(string: "General Chunk Size: \(chunkSize)")
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
                        throw SwiftyJSONError.invalidJSON
                    }
                    if nestedValue.type == .string {
                        let isContainsExcludedValue = excludedValues.first(where: { nestedString.lowercased().contains($0) }) != nil
                        guard !isContainsExcludedValue else {
                            return nil
                        }
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
                        throw SwiftyJSONError.invalidJSON
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
    
    private func filteredUrlString(_ url: URL?) -> URL? {
        guard let url = url else {
            return nil
        }

        let components = url.absoluteString.split(separator: "?")
        guard components.count == 2, let query = components.last else {
            return url
        }

        let isQueryContainsExcludedValues = excludedValues.first(where: { query.lowercased().contains($0) }) != nil        
        if isQueryContainsExcludedValues {
            return url.byTrimmingQuery
        } else {
            return url
        }
    }
}
