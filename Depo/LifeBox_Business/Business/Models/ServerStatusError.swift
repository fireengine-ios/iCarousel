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
        static let existPhone = "PHONE_NUMBER_IS_ALREADY_EXIST"
        static let existEmail = "EMAIL_ALREADY_EXISTS"
        static let verifyEmail = "VERIFY_EXISTING_EMAIL"
        static let invalidPhone = "PHONE_NUMBER_IS_INVALID"
        static let invalidPassword = "INVALID_PASSWORD"
        static let invalidPasswordConsecutive = "SEQUENTIAL_CHARACTERS"
        static let invalidPasswordSame = "SAME_CHARACTERS"
        static let invalidPasswordLengthExceeded = "PASSWORD_LENGTH_EXCEEDED"
        static let invalidPasswordBelowLimit = "PASSWORD_LENGTH_IS_BELOW_LIMIT"
        static let TOO_MANY_REQUESTS = "TOO_MANY_REQUESTS"
        static let EMAIL_IS_INVALID = "EMAIL_IS_INVALID"
        static let EMAIL_IS_ALREADY_EXIST = "EMAIL_IS_ALREADY_EXIST"
        static let invalidCaptcha = "Invalid captcha."
        static let captchaRequired = "Captcha required."
        static let tooManyInvalidAttepts = "TOO_MANY_INVALID_ATTEMPTS"
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
            return TextConstants.registrationPasswordError
            
        case ErrorKeys.invalidPasswordConsecutive:
            return TextConstants.errorInvalidPassword
            
        case ErrorKeys.invalidPasswordSame:
            return TextConstants.errorInvalidPasswordSame
            
        case ErrorKeys.invalidPasswordLengthExceeded:
            return TextConstants.errorInvalidPasswordLengthExceeded
            
        case ErrorKeys.invalidPasswordBelowLimit:
            return TextConstants.errorInvalidPasswordBelowLimit
            
        case ErrorKeys.TOO_MANY_REQUESTS:
            return TextConstants.TOO_MANY_REQUESTS
            
        case ErrorKeys.EMAIL_IS_INVALID:
            return TextConstants.EMAIL_IS_INVALID
            
        case ErrorKeys.EMAIL_IS_ALREADY_EXIST:
            return TextConstants.EMAIL_IS_ALREADY_EXIST
            
        case ErrorKeys.invalidCaptcha:
            return TextConstants.invalidCaptcha
            
        case ErrorKeys.captchaRequired:
            return TextConstants.captchaRequired
            
        case ErrorKeys.tooManyInvalidAttepts:
            return TextConstants.tooManyInvalidAttempt
            
        default:
            return status
        }
    }
}
