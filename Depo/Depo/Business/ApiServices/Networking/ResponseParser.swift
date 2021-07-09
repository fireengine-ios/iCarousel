//
//  ResponseParser.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ResponseParser {
    static func parse<T: DataMap>(data: Data) -> ResponseResult<T> {
        if let object = T(data: data) {
            return ResponseResult.success(object)
        } else {
            return ResponseResult.failed(MappingError(data: data))
        }
    }
    
    static func parseArray<T: DataMapArray>(data: Data) -> ResponseResult<[T]> {
        let object = T.array(from: data)
        return ResponseResult.success(object)
    }
    
    static func getBackendError(data: Data?, response: HTTPURLResponse?) -> Error? {
        guard let data = data, let statusCode = response?.statusCode else {
            return nil
        }
        if let value = JSON(data)["value"].string {
            return ServerValueError(value: value, code: statusCode)
        } else if let status = JSON(data)["status"].string {
            return ServerStatusError(status: status, code: statusCode)
        } else if let message = JSON(data)["errorMsg"].string {
            return ServerMessageError(message: message, code: statusCode, customErrorCode: JSON(data)["errorCode"].int)
        } else {
            return nil
        }
    }
}
