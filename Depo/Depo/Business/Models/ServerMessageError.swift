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
        static let accountNotFoundForMSISDN = "ACCOUNT_NOT_FOUND_FOR_MSISDN"
        static let canNotChangePassword = "CAN_NOT_CHANGE_PASSWORD"
        static let privateShareMessageLimit = "Invalid sharing message"
        static let privateSharePhoneOrMailLimit = "Invalid sharing subject"
        static let privateShareNumberOfItemsLimit = "Max sharing item limit exceeded"
        
        static let canNotSentOTPSms = "CAN_NOT_SENT_OTP_SMS"
        static let canNotChangePasswordForgotMyPassword = "CAN_NOT_CHANGE_PASSWORD"
        static let invalidReferenceToken = "INVALID_REFERENCE_TOKEN"
        static let tooManyRequests = "TOO_MANY_REQUESTS"
        static let accountNotFound = "ACCOUNT_NOT_FOUND"
        static let invalidOTP = "INVALID_OTP"
        static let securityQuestionInvalid = "SECURITY_QUESTION_ANSWER_OR_ID_INVALID"
        static let tooManyInvalidAttempt = "TOO_MANY_INVALID_ATTEMPTS"
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
        case ErrorKeys.accountNotFoundForMSISDN:
            return localized(.resetPasswordAccountNotFound)
        case ErrorKeys.canNotChangePassword:
            return localized(.resetPasswordCantChangePassword)
        case ErrorKeys.privateShareMessageLimit:
            return TextConstants.privateShareMessageLimit
        case ErrorKeys.privateSharePhoneOrMailLimit:
            return TextConstants.privateSharePhoneOrMailLimit
        case ErrorKeys.privateShareNumberOfItemsLimit:
            return TextConstants.privateShareNumberOfItemsLimit
        case ErrorKeys.canNotSentOTPSms:
            return localized(.canNotSentOtpSms)
        case ErrorKeys.canNotChangePasswordForgotMyPassword:
            return localized(.resetPasswordCantChangePassword)
        case ErrorKeys.invalidReferenceToken:
            return localized(.invalidRefenrenceCode)
        case ErrorKeys.tooManyRequests:
            return localized(.tooManyRequests)
        case ErrorKeys.accountNotFound:
            return localized(.noAccountFound)
        case ErrorKeys.invalidOTP:
            return localized(.invalidOtp)
        case ErrorKeys.securityQuestionInvalid:
            return localized(.securityQuestionInvalid)
        case ErrorKeys.tooManyInvalidAttempt:
            return TextConstants.tooManyInvalidAttempt
        default:
            return message
        }
    }
}

//MARK: - private share related
extension ServerMessageError {
    func getPrivateShareError() -> String {
        if let customErrorCode = customErrorCode {
            switch customErrorCode {
            case 4115:
                return TextConstants.privateShareMessageLimit
            case 4114:
                return TextConstants.privateSharePhoneOrMailLimit
            case 4116:
                return TextConstants.temporaryErrorOccurredTryAgainLater
            case 4118:
                return TextConstants.privateShareNumberOfItemsLimit
            case 4109:
                return localized(.privateShareEmptyListError)
            default:
                return errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
            }
        } else {
            return errorDescription ?? TextConstants.temporaryErrorOccurredTryAgainLater
        }
    }
}
