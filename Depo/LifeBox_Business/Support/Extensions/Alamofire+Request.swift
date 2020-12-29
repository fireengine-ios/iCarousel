//
//  Alamofire+Request.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire


extension SessionManager {
    func cancellAllRequests() {
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
}

/// to send string as request parameter
/// https://stackoverflow.com/a/28552198
/// Example: request(url, method: .post, encoding: text)
extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        request.fillContentType()
        return request
    }
}

/// to send array as request parameter
/// https://stackoverflow.com/a/39959559
extension Array: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = try JSONSerialization.data(withJSONObject: self, options: [])
        request.fillContentType()
        return request
    }
}

/// need to test for some more requests
/// maybe need set headers only in service
extension URLRequest {
    fileprivate mutating func fillContentType() {
        let header = "Content-Type"
        if value(forHTTPHeaderField: header) == nil {
            setValue("application/json", forHTTPHeaderField: header)
        }
    }
}



/// https://stackoverflow.com/questions/27026916/sending-json-array-via-alamofire/39959559#39959559
private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}

public struct ArrayEncoding: ParameterEncoding {
    
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}
