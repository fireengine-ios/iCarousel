//
//  Alamofire+Response.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

extension Alamofire.DataRequest {
    
    func responseArray<T: DataMapArray>(_ handler: @escaping ResponseArrayHandler<T>) {
        responseData { response in
            switch response.result {
            case .success(let data):
                handler(ResponseParser.parseArray(data: data))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
    
    @discardableResult
    func responseObject<T: DataMap>(_ handler: @escaping ResponseHandler<T>) -> Self {
        return responseData { response in
            switch response.result {
            case .success(let data):
                handler(ResponseParser.parse(data: data))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
    
    @discardableResult
    func responseVoid(_ handler: @escaping ResponseHandler<Void>) -> Self {
        return responseString { response in
            switch response.result {
            case .success(_):
                handler(ResponseResult.success(()))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
    
    @discardableResult
    func responsePlainString(_ handler: @escaping ResponseHandler<String>) -> Self {
        return responseString { response in
            switch response.result {
            case .success(let data):
                handler(ResponseResult.success((data)))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
    
    @discardableResult
    func responseObject<T: Codable>(_ handler: @escaping ResponseHandler<T>) -> Self {
        return responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let object = try JSONDecoder.withMillisecondsDate().decode(T.self, from: data)
                    handler(.success(object))
                } catch let error {
                    handler(.failed(error))
                }
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
    
    @discardableResult
    func responseArray<T: Codable>(_ handler: @escaping ResponseArrayHandler<T>) -> Self {
        return responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let objects = try JSONDecoder.withMillisecondsDate().decode([T].self, from: data)
                    handler(.success(objects))
                } catch let error {
                    handler(.failed(error))
                }
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }

    @discardableResult
    func responseObjectRequestResponse<T: ObjectRequestResponse>(_ handler: @escaping ResponseHandler<T>) -> Self {
        return responseData { response in
            switch response.result {
            case .success(let data):
                let result = T(json: data, headerResponse: response.response)
                handler(.success(result))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(ResponseResult.failed(backendError ?? error))
            }
        }
    }
}


extension JSONDecoder {
    static func withMillisecondsDate() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
