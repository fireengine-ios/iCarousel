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
        if case ErrorResponse.error(let error) = self, error is URLError {
            UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
        }   
    }
    
    var isOutOfSpaceError: Bool {
        if case ErrorResponse.httpCode(413) = self {
            return true
        }
        return false
    }
}

extension ErrorResponse: CustomStringConvertible {
    /// need to optimize this (remove from using)
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
            if recivedError.isNetworkError {
                return TextConstants.errorConnectedToNetwork
            }
            return recivedError.description
        case .httpCode(let code):
            return String(code)
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
        return isNetworkError ? TextConstants.errorConnectedToNetwork : localizedDescription
    }
}
