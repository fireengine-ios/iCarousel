//
//  ServerValueError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/5/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class ServerValueError {
    let value: String
    let code: Int
    
    init(value: String, code: Int) {
        self.value = value
        self.code = code
    }
    
    private struct ErrorKeys {
        static let ACCOUNT_NOT_FOUND = "ACCOUNT_NOT_FOUND"
        static let INVALID_PROMOCODE = "INVALID_PROMOCODE"
        static let PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED = "PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED"
        static let PROMO_CODE_HAS_BEEN_EXPIRED = "PROMO_CODE_HAS_BEEN_EXPIRED"
        static let PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT = "PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT"
        static let THERE_IS_AN_ACTIVE_JOB_RUNNING = "THERE_IS_AN_ACTIVE_JOB_RUNNING"
        static let CURRENT_JOB_IS_FINISHED_OR_CANCELLED = "CURRENT_JOB_IS_FINISHED_OR_CANCELLED"
        static let PROMO_IS_NOT_ACTIVATED = "PROMO_IS_NOT_ACTIVATED"
        static let PROMO_HAS_NOT_STARTED = "PROMO_HAS_NOT_STARTED"
        static let PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE = "PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE"
        static let PROMO_IS_INACTIVE = "PROMO_IS_INACTIVE"
        static let invalidCaptcha = "Invalid captcha."
        static let captchaRequired = "Captcha required."
    }
}
extension ServerValueError: LocalizedError {
    var errorDescription: String? {
        switch value {
        case ErrorKeys.ACCOUNT_NOT_FOUND:
            return TextConstants.ACCOUNT_NOT_FOUND
            
        case ErrorKeys.INVALID_PROMOCODE:
            return TextConstants.INVALID_PROMOCODE
            
        case ErrorKeys.PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED:
            return TextConstants.PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED
            
        case ErrorKeys.PROMO_CODE_HAS_BEEN_EXPIRED:
            return TextConstants.PROMO_CODE_HAS_BEEN_EXPIRED
            
        case ErrorKeys.PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT:
            return TextConstants.PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT
            
        case ErrorKeys.THERE_IS_AN_ACTIVE_JOB_RUNNING:
            return TextConstants.THERE_IS_AN_ACTIVE_JOB_RUNNING
            
        case ErrorKeys.CURRENT_JOB_IS_FINISHED_OR_CANCELLED:
            return TextConstants.CURRENT_JOB_IS_FINISHED_OR_CANCELLED
            
        case ErrorKeys.PROMO_IS_NOT_ACTIVATED:
            return TextConstants.PROMO_IS_NOT_ACTIVATED
            
        case ErrorKeys.PROMO_HAS_NOT_STARTED:
            return TextConstants.PROMO_HAS_NOT_STARTED
            
        case ErrorKeys.PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE:
            return TextConstants.PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE
            
        case ErrorKeys.PROMO_IS_INACTIVE:
            return TextConstants.PROMO_IS_INACTIVE
            
        case ErrorKeys.invalidCaptcha:
            return TextConstants.invalidCaptcha
            
        case ErrorKeys.captchaRequired:
            return TextConstants.captchaRequired
            
        default:
            /// maybe will be need
            /// TextConstants.promocodeError
            return TextConstants.errorServer
        }
    }
}
