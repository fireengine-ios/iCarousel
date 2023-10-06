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

    struct ErrorKeys {
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
        static let TOO_MANY_REQUESTS_EMAIL = "TOO_MANY_REQUESTS_EMAIL"
        static let TOO_MANY_REQUESTS_MSISDN = "TOO_MANY_REQUESTS_MSISDN"
        
        static let addressNotFound = "Address not found."
        static let cityNotFound = "City not found."
        static let districtNotFound = "District not found."
        static let maxAddressLimitExceed = "Max address limit exceeded."
        static let addressBookNotFound = "Address book not found."
        static let generalError = "General error."
        static let orderNotFound = "Photo print order not found."
        static let fileNotFound = "File not found."
        static let fileListIsEmpty = "File list is empty."
        static let downloadUrlNotFound = "Download url not found."
        static let printPackageNotFound = "Photo print package not found."
        static let limitExceeded = "Photo print limit exceeded."
        static let fileListLimitExceeded = "Photo print file list limit exceeded."
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

        case ErrorKeys.TOO_MANY_REQUESTS_EMAIL:
            return localized(.signUpTooManyRequestsEmail)

        case ErrorKeys.TOO_MANY_REQUESTS_MSISDN:
            return localized(.signUpTooManyRequestsMSISDN)
            
        case ErrorKeys.addressNotFound:
            return localized(.addressNotFound)
            
        case ErrorKeys.cityNotFound:
            return localized(.addressCityNotFound)
            
        case ErrorKeys.districtNotFound:
            return localized(.addressDistrictNotFound)
            
        case ErrorKeys.maxAddressLimitExceed:
            return localized(.addressBookMaxLimit)
            
        case ErrorKeys.addressBookNotFound:
            return localized(.addressBookNotFound)
            
        case ErrorKeys.generalError:
            return localized(.addressBookNotFound)
            
        case ErrorKeys.orderNotFound:
            return localized(.orderNotFound)
            
        case ErrorKeys.fileNotFound:
            return localized(.orderFileNotFound)
            
        case ErrorKeys.fileListIsEmpty:
            return localized(.orderUuidListEmpty)
            
        case ErrorKeys.downloadUrlNotFound:
            return localized(.downloadUrlNotFound)
            
        case ErrorKeys.printPackageNotFound:
            return localized(.printPackageNotFound)
            
        case ErrorKeys.limitExceeded:
            return localized(.printLimitExceededError)
            
        case ErrorKeys.fileListLimitExceeded:
            return localized(.printFileLimitExceededError)
            
        default:
            /// maybe will be need
            /// TextConstants.promocodeError
            return TextConstants.errorServer
        }
    }
}
