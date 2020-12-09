//
//  ServerMessageError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class ServerMessageError {
    let message: String
    let code: Int
    var customErrorCode: Int?
    
    init(message: String, code: Int, customErrorCode: Int? = nil) {
        self.message = message
        self.code = code
        self.customErrorCode = customErrorCode
    }
    
    private enum ErrorKeys {
        static let accountNotFoundForEmail = "ACCOUNT_NOT_FOUND_FOR_EMAIL"
        static let privateShareMessageLimit = "Invalid sharing message"
        static let privateShatePhoneOrMailLimit = "Invalid sharing subject"
    }
}
extension ServerMessageError: LocalizedError {
    var errorDescription: String? {
        if code == 500 {
            return TextConstants.errorServer
        }
        
        switch message {
        case ErrorKeys.accountNotFoundForEmail:
            return TextConstants.forgotPasswordErrorNotRegisteredText
        case ErrorKeys.privateShareMessageLimit:
            return TextConstants.privateShareMessageLimit
        case ErrorKeys.privateShatePhoneOrMailLimit:
            return TextConstants.privateSharePhoneOrMailLimit
        default:
            return message
        }
    }
}

//MARK: - private share related
extension ServerMessageError {
    func getPrivateShareError() -> String? {
        if let customErrorCode = customErrorCode {
            switch customErrorCode {
            case 4115:
                return TextConstants.privateShareMessageLimit
            case 4114:
                return TextConstants.privateSharePhoneOrMailLimit
            default:
                return TextConstants.temporaryErrorOccurredTryAgainLater
            }
        } else {
            return errorDescription
        }
    }
}
