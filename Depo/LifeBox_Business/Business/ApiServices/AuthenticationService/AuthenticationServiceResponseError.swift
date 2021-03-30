//
//  AuthenticationServiceResponseError.swift
//  Depo
//
//  Created by Andrei Novikau on 1/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum LoginResponseError: Error {
    case block
    case needCaptcha
    case authenticationDisabledForAccount
    case needSignUp
    case incorrectUsernamePassword
    case incorrectCaptcha
    case networkError
    case serverError
    case genericError
    case unauthorized
    case errorCode401
    case errorCode10
    case errorCode0
    case errorCode4201
    case errorCode30
    case errorCode31
    case errorCode32
    case errorCode33
    case noInternetConnection
    case emptyPhone
    case emptyCaptcha
    case emptyEmail

    case flNotInPool
    case flAuthFailure
    
    init(with errorResponse: ErrorResponse) {
        if errorResponse.description.contains(TextConstants.NotLocalized.flIdentifierKey) {
            if errorResponse.description.contains(TextConstants.flLoginAuthFailure) {
                self = .flAuthFailure
            } else if errorResponse.description.contains(TextConstants.flLoginUserNotInPool) {
                self = .flNotInPool
            } else {
                self = .serverError
            }
        }
        else if !ReachabilityService.shared.isReachable {
            self = .noInternetConnection
        }
        else if errorResponse.description.contains("Captcha required") {
            self = .needCaptcha
        }
        else if errorResponse.description.contains("Sign up required") {
            self = .needSignUp
        }
        else if errorResponse.description.contains("Invalid captcha") ||
                    errorResponse.description.contains("Unexpected char") {
            self = .incorrectCaptcha
        }
        else if errorResponse.description.contains("Internet") {
            self = .networkError
        }
        else if errorResponse.description.contains(HeaderConstant.emptyMSISDN) {
            self = .emptyPhone
        }
        else if errorResponse.description.contains(HeaderConstant.emptyEmail) {
            self = .emptyEmail
        } else if errorResponse.description.contains(ErrorResponseText.captchaIsEmpty) {
            self = .emptyCaptcha
        } else {
            guard let data: Data = errorResponse.description.data(using: .utf8),
                  let error: ServerErrorDescription = try? JSONDecoder().decode(ServerErrorDescription.self, from: data)
            else {
                self = .serverError
                return
            }
            
            switch error.errorCode {
            case 0:
                self = .errorCode0
            case 10:
                self = .errorCode10
            case 30:
                self = .errorCode30
            case 31:
                self = .errorCode31
            case 32:
                self = .errorCode32
            case 33:
                self = .errorCode33
            case 401:
                self = .errorCode401
            case 4201:
                self = .errorCode4201
            default:
                self = .genericError
            }
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
        case .incorrectUsernamePassword, .emptyPhone, .emptyEmail:
            return GADementionValues.loginError.incorrectUsernamePassword.text
        case .incorrectCaptcha:
            return GADementionValues.loginError.incorrectCaptcha.text
        case .networkError, .noInternetConnection:
            return GADementionValues.loginError.networkError.text
        case .unauthorized:
            return GADementionValues.loginError.unauthorized.text
        case .serverError:
            return GADementionValues.loginError.serverError.text
        case .emptyCaptcha:
            return GADementionValues.loginError.captchaIsEmpty.text
        default:
            // TODO: add analytics keys when appropriate task will be created
            return ""
        }
    }
}

struct ServerErrorDescription: Codable {
    var errorCode: Int
    var errorMessage: String
}

final class SignUpReasonError: Map {
    
    private enum JSONKeys {
        static let sequentialCharacterLimitKey = "sequentialCharacterLimit"
        static let sameCharacterLimit = "sameCharacterLimit"
        static let recentHistoryLimit = "recentHistoryLimit"
        static let reason = "reason"
        static let minimumCharacterLimit = "minimumCharacterLimit"
        static let maximumCharacterLimit = "maximumCharacterLimit"
    }
    
    enum Reason: String {
        case passwordLengthIsBelowLimit = "PASSWORD_LENGTH_IS_BELOW_LIMIT"
        case passwordLengthExceeded = "PASSWORD_LENGTH_EXCEEDED"
        case sequentialCharacters = "SEQUENTIAL_CHARACTERS"
        case sameCharacters = "SAME_CHARACTERS"
        case uppercaseMissing = "UPPERCASE_MISSING"
        case lowercaseMissing = "LOWERCASE_MISSING"
        case numberMissing = "NUMBER_MISSING"
    }
    
    let sequentialCharacterLimit: Int
    let sameCharacterLimit: Int
    let recentHistoryLimit: Int
    let reason: Reason?
    let minimumCharacterLimit: Int
    let maximumCharacterLimit: Int
    
    init(json: JSON) {
        sequentialCharacterLimit = json[JSONKeys.sequentialCharacterLimitKey].intValue
        sameCharacterLimit = json[JSONKeys.sameCharacterLimit].intValue
        recentHistoryLimit = json[JSONKeys.recentHistoryLimit].intValue
        reason = Reason(rawValue: json[JSONKeys.reason].stringValue)
        minimumCharacterLimit = json[JSONKeys.minimumCharacterLimit].intValue
        maximumCharacterLimit = json[JSONKeys.maximumCharacterLimit].intValue
    }
}

final class SignupResponseError: Map {
    
    enum Status {
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
        case serverErrorUnderMaintenance
        case incorrectCaptcha
        case captchaRequired
        case unauthorized
        
        init?(with stringValue: String) {
            switch stringValue {
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
    }
    
    private enum JSONKeys {
        static let value = "value"
        static let status = "status"
        static let errorMsg = "errorMsg"
        static let errorMessage = "errorMessage"
    }
    
    let status: Status?
    let errorReason: SignUpReasonError?
    
    init?(json: JSON) {
        if let valueString = json[JSONKeys.value].string {
            status = Status(with: valueString)
        } else if let statusString = json[JSONKeys.status].string {
            status = Status(with: statusString)
        } else if let errorMsg = json[JSONKeys.errorMsg].string {
            status = Status(with: errorMsg)
        } else if let errorMessage = json[JSONKeys.errorMessage].string {
            status = Status(with: errorMessage)
        } else {
            return nil
        }
        errorReason = SignUpReasonError(json: json[JSONKeys.value])
    }
    
    init(status: Status?) {
        self.status = status
        errorReason = nil
    }

    var isCaptchaError: Bool {
        switch status {
        case .captchaRequired, .incorrectCaptcha:
            return true
        default:
            return false
        }
    }
    
    var dimensionValue: String {
        switch status {
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
        case .serverError, .serverErrorUnderMaintenance:
            return GADementionValues.signUpError.serverError.text
        case .incorrectCaptcha:
            return GADementionValues.signUpError.incorrectCaptcha.text
        case .captchaRequired:
            return GADementionValues.signUpError.captchaRequired.text
        case .unauthorized:
            return GADementionValues.signUpError.unauthorized.text
        default:
            return GADementionValues.signUpError.serverError.text
        }
    }
}

extension SignupResponseError: LocalizedError {
    var errorDescription: String? {
        switch status {
        case .invalidEmail:
            return TextConstants.errorInvalidEmail
        case .invalidPhoneNumber:
            return TextConstants.errorInvalidPhone
        case .emailAlreadyExists:
            return TextConstants.EMAIL_IS_ALREADY_EXIST
        case .gsmAlreadyExists:
            return TextConstants.errorExistPhone
        case .invalidPassword:
            if let errorReason = errorReason {
                switch errorReason.reason {
                case .passwordLengthIsBelowLimit:
                    let format = TextConstants.signUpErrorPasswordLengthIsBelowLimit
                    return String(format: format, errorReason.minimumCharacterLimit)
                case .passwordLengthExceeded:
                    let format = TextConstants.signUpErrorPasswordLengthExceeded
                    return String(format: format, errorReason.maximumCharacterLimit)
                case .sequentialCharacters:
                    let format = TextConstants.signUpErrorSequentialCharacters
                    return String(format: format, errorReason.sequentialCharacterLimit)
                case .sameCharacters:
                    let format = TextConstants.signUpErrorSameCharacters
                    return String(format: format, errorReason.sameCharacterLimit)
                case .uppercaseMissing:
                    return TextConstants.signUpErrorUppercaseMissing
                case .lowercaseMissing:
                    return TextConstants.signUpErrorLowercaseMissing
                case .numberMissing:
                    return TextConstants.signUpErrorNumberMissing
                default:
                    return TextConstants.registrationPasswordError
                }
            }
            return TextConstants.registrationPasswordError
            
        case .tooManyOtpRequests:
            return TextConstants.TOO_MANY_REQUESTS
        case .invalidOtp:
            return TextConstants.invalidOTP
        case .tooManyInvalidOtpAttempts:
            return TextConstants.tooManyInvalidAttempt
        case .networkError:
            return TextConstants.networkConnectionLostTextError
        case .serverError:
            return TextConstants.errorServer
        case .serverErrorUnderMaintenance:
            return TextConstants.errorServerUnderMaintenance
        case .incorrectCaptcha:
            return TextConstants.invalidCaptcha
        case .captchaRequired:
            return TextConstants.captchaRequired
        case .unauthorized:
            return TextConstants.signUpErrorUnauthorized
        default:
            return TextConstants.signUpErrorUnauthorized
        }
    }
}


enum SpotifyResponseError: Error {
    case importError
    case networkError

    init?(with errorResponse: ErrorResponse) {
        if errorResponse.description.contains("412") {
            self = .importError
        } else {
            self = .networkError
        }
    }
    
    var dimensionValue: String {
        switch self {
        case .importError:
            return GADementionValues.spotifyError.importError.text
        case .networkError:
            return GADementionValues.spotifyError.networkError.text
        }
    }
    
}
