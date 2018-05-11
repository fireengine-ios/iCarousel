//
//  ErrorResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/5/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum ErrorResponse {
    case failResponse(ObjectFromRequestResponse?)
    case error(Error)
    case string(String)
    case httpCode(NSInteger)
}

extension ErrorResponse {
    func showInternetErrorGlobal() {
        if case ErrorResponse.error(let error) = self, error.isNetworkError {
            UIApplication.showErrorAlert(message: error.description)
        }
    }
    
    var isOutOfSpaceError: Bool {
        if case ErrorResponse.httpCode(413) = self {
            return true
        } else if case ErrorResponse.error(let error) = self,
            let serverValueError = error as? ServerValueError,
            serverValueError.code == 413 ///also value: "COPY"
        {
            return true
        }
        return false
    }
}

extension ErrorResponse: CustomStringConvertible {
    var description: String {
        return localizedDescription
    }
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failResponse(_):
            return TextConstants.errorServer
        case .string(let errorString):
            return errorString
        case .error(let recivedError):
            return recivedError.description
        case .httpCode(let code):
            #if DEBUG
            return String(code)
            #else
            return TextConstants.errorServer
            #endif
        }
    }
    
    var isNetworkError: Bool {
        if case let ErrorResponse.error(error) = self {
            return error.isNetworkError
        }
        return false
    }
}

extension Error {
    var description: String {
        if isNetworkError {
            switch urlErrorCode {
            case .notConnectedToInternet:
                return TextConstants.errorConnectedToNetwork
            default:
                return TextConstants.errorBadConnection
            }
        }
        
        return localizedDescription
    }
}
