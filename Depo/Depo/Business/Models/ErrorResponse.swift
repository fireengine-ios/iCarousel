//
//  ErrorResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/5/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

enum ErrorResponse {
    case failResponse(ObjectFromRequestResponse?)
    case error(Error)
    case string(String)
    case httpCode(NSInteger)
}

enum ErrorResponseText {
    static let serviceAnavailable = "503 Service Unavailable"
    static let resendCodeExceeded  = "EXCEEDED_RATE_LIMIT_FOR_SEND_CHALLENGE"
    static let accountDeleted = "DELETION_REQUESTED"
    static let accountReadOnly = "READ_ONLY"
    static let captchaIsEmpty = "CAPTCHA_FIELD_IS_EMPTY"
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
        } else if case ErrorResponse.error(let error) = self, error.isOutOfSpaceError {
            return true
        }
        return false
    }
    
    var isServerUnderMaintenance: Bool {
        if case ErrorResponse.string(let error) = self, error.contains(ErrorResponseText.serviceAnavailable) || error.contains(TextConstants.errorServerUnderMaintenance) {
            return true
        } else if case ErrorResponse.httpCode(503) = self {
            return true
        }
        
        return false
    }
    
    var isNetworkConnectionMissing: Bool {
        let code: URLError.Code

        switch self {
        case .error(let error):
            code = error.urlErrorCode
        default:
            code = urlErrorCode
        }

        return [.notConnectedToInternet, .networkConnectionLost].contains(code)
    }
}

extension ErrorResponse: CustomStringConvertible {
    var description: String {
        if isNetworkError {
            switch urlErrorCode {
            case .notConnectedToInternet, .networkConnectionLost:
                return TextConstants.errorConnectedToNetwork
            default:
                return TextConstants.errorBadConnection
            }
        } else if isServerUnderMaintenance {
            return TextConstants.errorServerUnderMaintenance
        }
        
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
    
    var isUnknownError: Bool {
        if case let ErrorResponse.error(error) = self {
            return error.isUnknownError
        }
        return false
    }
    
}

extension Error {
    
    var isServerUnderMaintenance: Bool {
        if let error = self as? AFError {
            return error.responseCode == 503
        } else if let error = self as? ServerError {
            return error.code == 503
        } else if let error = self as? ServerValueError {
            return error.code == 503
        } else if let error = self as? ServerStatusError {
            return error.code == 503
        } else if let error = self as? ServerMessageError {
            return error.code == 503
        } else if let error = self as? ErrorResponse {
            return error.isServerUnderMaintenance
        }
        
        return false
    }
    
    var isOutOfSpaceError: Bool {
        if let error = self as? AFError {
            return error.responseCode == 413
        } else if let error = self as? ServerError {
            return error.code == 413
        } else if let error = self as? ServerValueError {
            return error.code == 413
        } else if let error = self as? ServerStatusError {
            return error.code == 413
        } else if let error = self as? ServerMessageError {
            return error.code == 413
        } else if let error = self as? ErrorResponse {
            return error.isOutOfSpaceError
        }
        
        return false
    }
    
    var isNetworkSpecialError: Bool {
        if isNetworkError {
            return true
        } else if isServerUnderMaintenance {
            return true
        } else {
            return false
        }
    }
    
    var description: String {
        if isNetworkError {
            switch urlErrorCode {
            case .notConnectedToInternet, .networkConnectionLost:
                return TextConstants.errorConnectedToNetwork
            default:
                return TextConstants.errorBadConnection
            }
        } else if isServerUnderMaintenance {
            return TextConstants.errorServerUnderMaintenance
        }
        
        return localizedDescription
    }
    
    var localizedDescription: String {
        let description = NSError(domain: _domain, code: _code, userInfo: _userInfo as? [String : Any]).localizedDescription
        if let errorResponse = self as? ErrorResponse {
            return errorResponse.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let customError = self as? CustomErrors {
            return customError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let singupError = self as? SignupResponseError {
            return singupError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let loginError = self as? LoginResponseError {
            return loginError.dimensionValue
        } else if let serverStatusError = self as? ServerStatusError {
            return serverStatusError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let passwordError = self as? UpdatePasswordErrors {
            return passwordError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let serverError = self as? ServerError {
            return serverError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let serverValueError = self as? ServerValueError {
            return serverValueError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let serverMessageError = self as? ServerMessageError {
            return serverMessageError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if let setSecretQuestionError = self as? SetSecretQuestionErrors {
            return setSecretQuestionError.errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        } else if description.contains("\(_code)") {
            return TextConstants.temporaryErrorOccurredTryAgainLater
        } else {
            return description
        }
    }
    
}
