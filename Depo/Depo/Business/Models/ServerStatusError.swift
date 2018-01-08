//
//  ServerStatusError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class ServerStatusError {
    let status: String
    let code: Int
    
    init(status: String, code: Int) {
        self.status = status
        self.code = code
    }
    
    private struct ErrorKeys {
        static let emptyEmail = "EMAIL_FIELD_IS_EMPTY"
        static let emptyPassword = "PASSWORD_FIELD_IS_EMPTY"
        static let emptyPhone = "PHONE_NUMBER_FIELD_IS_EMPTY"
        static let invalidEmail = "EMAIL_FIELD_IS_INVALID"
        static let existEmail = "EMAIL_IS_ALREADY_EXIST"
        static let existPhone = "PHONE_NUMBER_IS_ALREADY_EXIST"
        static let verifyEmail = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPhone = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPassword = "INVALID_PASSWORD"
        static let invalidPasswordConsecutive = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordSame = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordLengthExceeded = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordBelowLimit = "PASSWORD_FIELD_IS_EMPTY"
        static let manyRequest = "PASSWORD_FIELD_IS_EMPTY"
        
        static let TOO_MANY_REQUESTS = "TOO_MANY_REQUESTS"
        static let EMAIL_IS_INVALID = "EMAIL_IS_INVALID"
    }
}
extension ServerStatusError: LocalizedError {
    var errorDescription: String? {
        switch status {
        case ErrorKeys.emptyEmail:
            return TextConstants.errorEmptyEmail
            
        case ErrorKeys.emptyPassword:
            return TextConstants.errorEmptyPassword
            
        case ErrorKeys.emptyPhone:
            return TextConstants.errorEmptyPhone
            
        case ErrorKeys.invalidEmail:
            return TextConstants.errorInvalidEmail
            
        case ErrorKeys.existEmail:
            return TextConstants.errorExistEmail
            
        case ErrorKeys.verifyEmail:
            return TextConstants.errorVerifyEmail
            
        case ErrorKeys.invalidPhone:
            return TextConstants.errorInvalidPhone
            
        case ErrorKeys.existPhone:
            return TextConstants.errorExistPhone
        
        case ErrorKeys.invalidPassword:
            return TextConstants.errorInvalidPassword
            
        case ErrorKeys.invalidPasswordConsecutive:
            return TextConstants.errorInvalidPasswordConsecutive
            
        case ErrorKeys.invalidPasswordSame:
            return TextConstants.errorInvalidPasswordSame
            
        case ErrorKeys.invalidPasswordLengthExceeded:
            return TextConstants.errorInvalidPasswordLengthExceeded
            
        case ErrorKeys.invalidPasswordBelowLimit:
            return TextConstants.errorInvalidPasswordBelowLimit
            
        case ErrorKeys.manyRequest:
            return TextConstants.errorManyRequest
            
        case ErrorKeys.TOO_MANY_REQUESTS:
            return TextConstants.TOO_MANY_REQUESTS
            
        case ErrorKeys.EMAIL_IS_INVALID:
            return TextConstants.EMAIL_IS_INVALID
            
        default:
            return status
        }
    }
}
