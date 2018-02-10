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
extension ErrorResponse: CustomStringConvertible {
    var description: String {
        return errorDescription ?? TextConstants.errorUnknown
    }
    
    func showInternetErrorGlobal() {
        if case ErrorResponse.error(let error) = self, error is URLError {
            UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
        }
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
            if recivedError is URLError {
                return TextConstants.errorConnectedToNetwork
            }
            return recivedError.localizedDescription
        case .httpCode(let code):
            return String(code)
        }
    }
}
