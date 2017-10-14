//
//  BackendError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class BackendError: Error {
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
        static let verifyEmail = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPhone = "PASSWORD_FIELD_IS_EMPTY"
        static let existPhone = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPassword = "INVALID_PASSWORD"
        static let invalidPasswordConsecutive = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordSame = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordLengthExceeded = "PASSWORD_FIELD_IS_EMPTY"
        static let invalidPasswordBelowLimit = "PASSWORD_FIELD_IS_EMPTY"
        static let manyRequest = "PASSWORD_FIELD_IS_EMPTY"
    }
    
    var localizedDescription: String {
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
            
        default:
            return TextConstants.errorUnknown
        }
    }
}
