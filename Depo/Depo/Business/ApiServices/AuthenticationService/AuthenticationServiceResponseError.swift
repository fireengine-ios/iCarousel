//
//  AuthenticationServiceResponseError.swift
//  Depo
//
//  Created by Andrei Novikau on 1/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

enum LoginResponseError {
    case block
    case needCaptcha
    case authenticationDisabledForAccount
    case needSignUp
    case incorrectUsernamePassword
    case incorrectCaptcha
    case networkError
    case serverError
    case unauthorized
    case noInternetConnection
    case emptyPhone
    
    init(with errorResponse: ErrorResponse) {
        if errorResponse.description.contains("LDAP account is locked") {
            self = .block
        }
        else if !ReachabilityService().isReachable {
            self = .noInternetConnection
        }
        else if errorResponse.description.contains("Captcha required") {
            self = .needCaptcha
        }
        else if errorResponse.description.contains("Authentication with Turkcell Password is disabled for the account") {
            self = .authenticationDisabledForAccount
        }
        else if errorResponse.description.contains("Sign up required") {
            self = .needSignUp
        }
        else if errorResponse.description.contains("Authentication failure") || errorResponse.description.contains("LDAP system failure") {
            self = .incorrectUsernamePassword
        }
        else if errorResponse.description.contains("Invalid captcha") {
            self = .incorrectCaptcha
        }
        else if errorResponse.description.contains("Internet") {
            self = .networkError
        }
        else if errorResponse.description.contains(HeaderConstant.emptyMSISDN) {
            self = .emptyPhone
        }
        else if case ErrorResponse.error(let error) = errorResponse, let statusError = error as? ServerStatusError, statusError.code == 401 {
            self = .unauthorized
        }
        else {
            self = .serverError
        }
    }
    
    var dimensionValue: String {
        switch self {
        case .block:
            return GADementionValues.loginError.accountIsBlocked.text
        case .needCaptcha:
            return GADementionValues.loginError.captchaRequired.text
        case .authenticationDisabledForAccount:
            return GADementionValues.loginError.turkcellPasswordDisabled.text
        case .needSignUp:
            return GADementionValues.loginError.signupRequired.text
        case .incorrectUsernamePassword, .emptyPhone:
            return GADementionValues.loginError.incorrectUsernamePassword.text
        case .incorrectCaptcha:
            return GADementionValues.loginError.incorrectCaptcha.text
        case .networkError, .noInternetConnection:
            return GADementionValues.loginError.networkError.text
        case .unauthorized:
            return GADementionValues.loginError.unauthorized.text
        case .serverError:
            return GADementionValues.loginError.serverError.text
        }
    }
}

enum SignupResponseError {
    case invalidEmail
    case invalidPhoneNumber
    case emailAlreadyExists
    case gsmAlreadyExists
    case invalidPassword
    case tooManyOtpRequests
    case invalidOtp
    case tooManyInvalidOtpAttempts
    case networkError
    case serverError
    case incorrectCaptcha
    case captchaRequired
    case unauthorized
    
    init?(with error: ServerStatusError) {
        self.init(with: error.status)
    }
    
    init?(with error: ServerValueError) {
        self.init(with: error.value)
    }
    
    init?(with stringError: String) {
        switch stringError {
        case "EMAIL_FIELD_IS_INVALID", "EMAIL_IS_INVALID":
            self = .invalidEmail
        case "EMAIL_IS_ALREADY_EXIST":
            self = .emailAlreadyExists
        case "PHONE_NUMBER_IS_ALREADY_EXIST":
            self = .gsmAlreadyExists
        case "INVALID_PASSWORD":
            self = .invalidPassword
        case "TOO_MANY_REQUESTS":
            self = .tooManyOtpRequests
        case "INVALID_OTP":
            self = .invalidOtp
        case "TOO_MANY_INVALID_ATTEMPTS":
            self = .tooManyInvalidOtpAttempts
        case "INVALID_CAPTCHA", "Invalid captcha.":
            self = .incorrectCaptcha
        case "Captcha required.":
            self = .captchaRequired
        case "PHONE_NUMBER_IS_INVALID":
            self = .invalidPhoneNumber
        default:
            return nil
        }
    }
    
    var dimensionValue: String {
        switch self {
        case .invalidEmail:
            return GADementionValues.signUpError.invalidEmail.text
        case .invalidPhoneNumber:
            return GADementionValues.signUpError.invalidPhoneNumber.text
        case .emailAlreadyExists:
            return GADementionValues.signUpError.emailAlreadyExists.text
        case .gsmAlreadyExists:
            return GADementionValues.signUpError.gsmAlreadyExists.text
        case .invalidPassword:
            return GADementionValues.signUpError.invalidPassword.text
        case .tooManyOtpRequests:
            return GADementionValues.signUpError.tooManyOtpRequests.text
        case .invalidOtp:
            return GADementionValues.signUpError.invalidOtp.text
        case .tooManyInvalidOtpAttempts:
            return GADementionValues.signUpError.tooManyInvalidOtpAttempts.text
        case .networkError:
            return GADementionValues.signUpError.networkError.text
        case .serverError:
            return GADementionValues.signUpError.serverError.text
        case .incorrectCaptcha:
            return GADementionValues.signUpError.incorrectCaptcha.text
        case .captchaRequired:
            return GADementionValues.signUpError.captchaRequired.text
        case .unauthorized:
            return GADementionValues.signUpError.unauthorized.text
        }
    }
}
