//
//  FirebaseAnalyticsDementions.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum GADementionsFields {
    case screenName
    case pageType
    case sourceType
    case loginStatus
    case loginType
    case platform
    case networkFixWifi
    case service
    case developmentVersion
    case paymentMethod
    case userID
    case operatorSystem ///Carrier Name should be sent for every page click.
    case faceImageStatus
    case userPackage
    case gsmOperatorType
    case connectStatus
    case deviceId
    case errorType
    case autoSyncState
    case autoSyncStatus
    case twoFactorAuth
    case spotifyStatus
    case dailyDrawleft
    case itemsCount(GAOperationType)
    case editFields
    case connectionStatus
    case statusType
    case usagePercentage
    case photoEditFilterType
    
    var text: String {
        switch self {
        case .screenName:
            return "screenName"
        case .pageType:
            return "pageType"
        case .sourceType:
            return "sourceType"
        case .loginStatus:
            return "loginStatus"
        case .loginType:
            return "loginType"
        case .platform:
            return "platform"
        case .networkFixWifi:
            return "isWifi"
        case .service:
            return "service"
        case .developmentVersion:
            return "developmentVersion"
        case .paymentMethod:
            return "paymentMethod"
        case .userID:
            return "userId"
        case .operatorSystem:
            return "operatorSystem"
        case .faceImageStatus:
            return "facialRecognition"
        case .userPackage:
            return "userPackage"
        case .gsmOperatorType:
            return "gsmOperatorType"
        case .connectStatus:
            return "connectStatus"
        case .deviceId:
            return "deviceid"
        case .errorType:
            return "errorType"
        case .autoSyncState:
            return "AutoSync"
        case .autoSyncStatus:
            return "SyncStatus"
        case .twoFactorAuth:
            return "twoFactorAuthentication"
        case .spotifyStatus:
            return "connectStatus"
        case .dailyDrawleft:
            return "dailyDrawleft"
        case .itemsCount(let operationType):
            return operationType.itemsCountText
        case .editFields:
            return "editFields"
        case .connectionStatus:
            return "connectionStatus"
        case .statusType:
            return "statusType"
        case .usagePercentage:
            return "quotaStatus"
        case .photoEditFilterType:
            return "filterType"
        }
    }
    
}

enum GAMetrics {
    case countOfUpload //After uploading of all files in the upload queue finihes, send the count of uploaded files
    case countOfDownload //After downloading finishes, send the count of downloaded files
    case playlistNumber
    case trackNumber
    case totalDraw
    
    case errorType
    
    var text: String {
        switch self {
        case .countOfUpload:
            return "countOfUpload"
        case .countOfDownload:
            return "countOfDownload"
        case .playlistNumber:
            return "playlistNumber"
        case .trackNumber:
            return "trackNumber"
        case .totalDraw:
            return "totalDraw"
        case .errorType:
            return "errorType"
        }
    }
}

enum GADementionValues {
    typealias ItemsOperationCount = (count: Int, operationType: GAOperationType)
    
    enum login {
        case gsm
        case email
        case rememberLogin
        case turkcellGSM
        var text: String {
            switch self {
            case .gsm:
                return "GSM no ile şifreli giriş"
            case .email:
                return "Email ile giriş"
            case .rememberLogin:
                return "Beni hatırla ile giriş"
            case .turkcellGSM:
                return "Header Enrichment (cellular) ile giriş"
            }
        }
    }
    
    enum loginError {
        case incorrectUsernamePassword
        case incorrectCaptcha
        case accountIsBlocked
        case signupRequired
        case turkcellPasswordDisabled
        case captchaRequired
        case networkError
        case serverError
        case unauthorized
        case captchaIsEmpty
        
        var text: String {
            switch self {
            case .incorrectUsernamePassword:
                return "INCORRECT_USERNAME_PASSWORD"
            case .incorrectCaptcha:
                return "INCORRECT_CAPTCHA"
            case .accountIsBlocked:
                return "ACCOUNT_IS_BLOCKED"
            case .signupRequired:
                return "SIGNUP_REQUIRED"
            case .turkcellPasswordDisabled:
                return "TURKCELL_PASSWORD_DISABLED"
            case .captchaRequired:
                return "CAPTCHA_REQUIRED"
            case .networkError:
                return "NETWORK_ERROR"
            case .serverError:
                return "SERVER_ERROR"
            case .unauthorized:
                return "UNAUTHORIZED"
            case .captchaIsEmpty:
                return "EMPTY_CAPTCHA"
            }
        }
    }
    
    enum signUpError {
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
        case invalidMailOtp
        case tooManyInvalidMailOtpAttempts

        var text: String {
            switch self {
            case .invalidEmail:
                return "INVALID_EMAIL"
            case .invalidPhoneNumber:
                return "PHONE_NUMBER_IS_INVALID"
            case .emailAlreadyExists:
                return "EMAIL_ALREADY_EXISTS"
            case .gsmAlreadyExists:
                return "GSM_ALREADY_EXISTS"
            case .invalidPassword:
                return "INVALID_PASSWORD"
            case .tooManyOtpRequests:
                return "TOO_MANY_OTP_REQUESTS"
            case .invalidOtp:
                return "INVALID_OTP"
            case .tooManyInvalidOtpAttempts:
                return "TOO_MANY_INVALID_OTP_ATTEMPTS"
            case .networkError:
                return "NETWORK_ERROR"
            case .serverError:
                return "SERVER_ERROR"
            case .incorrectCaptcha:
                return "INCORRECT_CAPTCHA"
            case .captchaRequired:
                return "CAPTCHA_REQUIRED"
            case .unauthorized:
                return "UNAUTHORIZED"
            case .invalidMailOtp:
                return "INVALID_MAIL_OTP"
            case .tooManyInvalidMailOtpAttempts:
                return "TOO_MANY_INVALID_MAIL_OTP_ATTEMPTS"
            }
        }
    }
    
    enum spotifyError {
        case importError
        case networkError

        var text: String {
            switch self {
            case .importError:
                return "SPOTIFY_IMPORT_ERROR"
            case .networkError:
                return "NETWORK_ERROR"
            }
        }
    }
    
    enum errorType {
        /// MyProfile
        case emptyEmail
        case phoneInvalidFormat
        case emailInvalidFormat
        case emailInUse
        case phoneInUse
        /// Two Factor Authentification
        case invalidOTPCode
        case invalidSession
        case invalidChallenge
        case tooManyInvalidAttempts
        /// Email Verification
        case accountNotFound
        case referenceTokenIsEmpty
        case expiredOTP
        case invalidEmail
        case invalidOTP
        case tooManyRequests
        /// Secret Question
        case invalidCaptcha
        case invalidId
        case invalidAnswer
        
        init?(with stringError: String) {
            switch stringError {
            case TextConstants.errorInvalidPhone:
                self = .phoneInvalidFormat
                
            case TextConstants.errorExistPhone:
                self = .phoneInUse
                
            case TextConstants.invalidOTP:
                self = .invalidOTP
                
            case "INVALID_OTP_CODE":
                self = .invalidOTPCode
                
            case TextConstants.expiredOTP:
                self = .expiredOTP
                
            case TextConstants.emptyEmail, HeaderConstant.emptyEmail:
                self = .emptyEmail
                
            case TextConstants.invalidEmail:
                self = .invalidEmail
                
            case TextConstants.errorInvalidEmail:
                self = .emailInvalidFormat
                
            case TextConstants.errorExistEmail:
                self = .emailInUse
                
            case "INVALID_SESSION":
                self = .invalidSession
                
            case "INVALID_CHALLENGE":
                self = .invalidChallenge
                
            case TextConstants.TOO_MANY_REQUESTS, "TOO_MANY_REQUESTS", TextConstants.tooManyRequests:
                self = .tooManyRequests
                
            case "TOO_MANY_INVALID_ATTEMPTS", TextConstants.tooManyInvalidAttempt:
                self = .tooManyInvalidAttempts
                
            case TextConstants.ACCOUNT_NOT_FOUND, TextConstants.noAccountFound:
                self = .accountNotFound
                
            case TextConstants.tokenIsMissing:
                self = .referenceTokenIsEmpty
                
            case "SEQURITY_QUESTION_ANSWER_IS_INVALID":
                self = .invalidAnswer
                
            case "SEQURITY_QUESTION_ID_IS_INVALID":
                self = .invalidId

            case "4001":
                self = .invalidCaptcha
                
            default:
                return nil
            }
        }
        
        var text: String {
            switch self {
            case .emptyEmail:
                return "EMPTY_E-MAIL_ERROR"
                
            case .phoneInvalidFormat:
                return "PHONE_NUMBER_INVALID_FORMAT_ERROR"
                
            case .emailInvalidFormat:
                return "EMAIL_INVALID_FORMAT_ERROR"
                
            case .emailInUse:
                return "EMAIL_IN_USE_ERROR"
                
            case .phoneInUse:
                return "PHONE_NUMBER_IN_USE_ERROR"
                
            case .invalidOTPCode:
                return "INVALID_OTP_CODE"
                
            case .invalidSession:
                return "INVALID_SESSION"
                
            case .invalidChallenge:
                return "INVALID_CHALLENGE"
                
            case .tooManyInvalidAttempts:
                return "TOO_MANY_INVALID_ATTEMPTS"
                
            case .accountNotFound:
                return "ACCOUNT_NOT_FOUND"
                
            case .referenceTokenIsEmpty:
                return "REFERENCE_TOKEN_IS_EMPTY"
                
            case .expiredOTP:
                return "EXPIRED_OTP"
                
            case .invalidEmail:
                return "INVALID_EMAIL"
                
            case .invalidOTP:
                return "INVALID_OTP"
                
            case .tooManyRequests:
                return "TOO_MANY_REQUESTS"
                
            case .invalidCaptcha:
                return "INVALID_CAPTCHA"
                
            case .invalidId:
                return "SEQURITY_QUESTION_ID_IS_INVALID"
                
            case .invalidAnswer:
                return "SEQURITY_QUESTION_ANSWER_IS_INVALID"
                
            }
        }
    }
}
