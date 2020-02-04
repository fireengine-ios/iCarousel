//
//  AuthenticationService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

typealias SuccessResponse = (_ value: ObjectFromRequestResponse? ) -> Void
typealias FailResponse = (_ value: ErrorResponse) -> Void
typealias TwoFactorAuthResponse = (_ value: TwoFactorAuthErrorResponse) -> Void

class AuthenticationUser: BaseRequestParametrs {
    
    let login: String
    let password: String
    let rememberMe: Bool
    let attachedCaptcha: CaptchaParametrAnswer?
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.username   : login,
                                   LbRequestkeys.password   : password,
                                   LbRequestkeys.deviceInfo : Device.deviceInfo,
                                   LbRequestkeys.language   : Locale.current.languageCode ?? "",
                                   LbRequestkeys.appVersion : AuthoritySingleton.shared.getBuildVersion(),
                                   LbRequestkeys.osVersion  : Device.systemVersion]
        return dict
    }
    
    override var patch: URL {
        var patch: String = RouteRequests.httpsAuthification
        let rememberMeValue = rememberMe ? LbRequestkeys.on : LbRequestkeys.off
        patch = String(format: patch, rememberMeValue)
        
        return URL(string: patch, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        var result = super.header
        
        if let captcha = attachedCaptcha {
            result = result + captcha.header
        }
        return result
    }
    
    init(login: String, password: String, rememberMe: Bool, attachedCaptcha: CaptchaParametrAnswer?) {
        self.login = login
        self.password = password
        self.rememberMe = rememberMe
        self.attachedCaptcha = attachedCaptcha
    }
}


class Authentication3G: BaseRequestParametrs {
    
    override var requestParametrs: Any {
        return Device.deviceInfo
    }
    
    override var patch: URL {
        let patch = String(format: RouteRequests.unsecuredAuthenticationUrl, LbRequestkeys.on)
        return URL(string: patch,
                   relativeTo: super.patch)!
    }
}

class SigngOutParametes: BaseRequestParametrs {
    let authToken: String
    let rememberMeToken: String
    
    init(authToken: String, rememberMeToken: String) {
        self.authToken = authToken
        self.rememberMeToken = rememberMeToken
        super.init()
    }

//    override var requestParametrs: Any {
//
//    }
    override var header: RequestHeaderParametrs {
        return [
            HeaderConstant.AuthToken: authToken,
            HeaderConstant.RememberMeToken: rememberMeToken,
            HeaderConstant.Accept: HeaderConstant.ApplicationJson
        ]
    }
    
    override var patch: URL {
        let patch = RouteRequests.logout
        return URL(string: patch,
                   relativeTo: super.patch)!
    }
}

class SignUpUser: BaseRequestParametrs {
    
    let phone: String
    let mail: String
    let password: String
    let sendOtp: Bool
    let captchaID: String?
    let captchaAnswer: String?
    var brandType: String {
        #if LIFEDRIVE 
            return "BILLO"
        #else
            return "LIFEBOX"
        #endif
    }

    override var requestParametrs: Any {
        return [
            LbRequestkeys.email: mail,
            LbRequestkeys.phoneNumber: phone,
            LbRequestkeys.password: password,
            LbRequestkeys.language: Device.locale,
            LbRequestkeys.sendOtp: sendOtp,
            LbRequestkeys.brandType: brandType,
            LbRequestkeys.passwordRuleSetVersion: NumericConstants.passwordRuleSetVersion
        ]
    }

    override var header: RequestHeaderParametrs {
        guard let unwrapedCaptchaID = captchaID,
            let unwrapedCaptchaAnswer = captchaAnswer else {
                return RequestHeaders.authification()
        }
        return RequestHeaders.authificationWithCaptcha(id: unwrapedCaptchaID, answer: unwrapedCaptchaAnswer)
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.signUp, relativeTo: super.patch)!
    }

    init(phone: String, mail: String, password: String, sendOtp: Bool, captchaID: String? = nil, captchaAnswer: String? = nil) {
        self.phone = phone
        self.mail = mail
        self.password = password
        self.sendOtp = sendOtp
        self.captchaID = captchaID
        self.captchaAnswer = captchaAnswer
    }
    
    init(registrationUserInfo: RegistrationUserInfoModel, sentOtp: Bool) {
        self.phone = registrationUserInfo.phone
        self.mail = registrationUserInfo.mail
        self.password = registrationUserInfo.password
        self.sendOtp = sentOtp
        self.captchaID = registrationUserInfo.captchaID
        self.captchaAnswer = registrationUserInfo.captchaAnswer
    }
}

struct SignUpUserPhoveVerification: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let token: String
    let otp: String
    
    var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.referenceToken      : token,
                                   LbRequestkeys.otp                 : otp]

        return dict
    }
    
    var patch: URL {
        return URL(string: RouteRequests.phoneVerification, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


struct  ForgotPassword: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let email: String
    let attachedCaptcha: CaptchaParametrAnswer?
    
    
    var requestParametrs: Any {
        return  email.data(using: .utf8) ?? Data()
    }
    
    var patch: URL {
        return URL(string: RouteRequests.forgotPassword, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        if let captcha = attachedCaptcha {
            return RequestHeaders.base() + captcha.header
        }
        return RequestHeaders.base()
    }
}

class EmailUpdate: BaseRequestParametrs {
    let email: String
    
    init(mail: String) {
        email = mail
    }
    
    override var requestParametrs: Any { 
        return email
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.mailUpdate, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.authification()//base()
    }
}

class EmailVerification: BaseRequestParametrs {
    
    let email: String
    
    init(mail: String) {
        email = mail
    }
    
    override var requestParametrs: Any {
        return [LbRequestkeys.email : email]
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.mailVerification, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


struct ResendVerificationSMS: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let refreshToken: String
    let eulaId: Int
    let processPersonalData: Bool
    let etkAuth: Bool
    let globalPermAuth: Bool
    
    var requestParametrs: Any {
        return [LbRequestkeys.referenceToken : refreshToken,
                LbRequestkeys.eulaId : eulaId,
                LbRequestkeys.processPersonalData : processPersonalData,
                LbRequestkeys.etkAuth : etkAuth,
                LbRequestkeys.globalPermAuth: globalPermAuth]
    }
    
    var patch: URL {
        return URL(string: RouteRequests.resendVerificationSMS, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


typealias  SuccessLogin = () -> Void
typealias  SuccessLogout = () -> Void
typealias  FailLoginType = FailResponse
typealias  HeadersHandler = ([String: Any]) -> Void

class AuthenticationService: BaseRequestService {
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var authorizationSevice: AuthorizationRepository = factory.resolve()
    private lazy var sessionManager: SessionManager = factory.resolve()

    // MARK: - Login
    
    func login(user: AuthenticationUser, sucess: HeadersHandler?, fail: FailResponse?, twoFactorAuth: TwoFactorAuthResponse?) {
        debugLog("AuthenticationService loginUser")
        
        storageVars.currentUserID = user.login
        
        let params: [String: Any] = ["username": user.login,
                                     "password": user.password,
                                     LbRequestkeys.deviceInfo: Device.deviceInfo]
        
        SessionManager.customDefault.request(user.patch, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: user.attachedCaptcha?.header)
                .responseString { [weak self] response in
                    switch response.result {
                    case .success(_):
                        guard let headers = response.response?.allHeaderFields as? [String: Any] else {
                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                            fail?(ErrorResponse.error(error))
                            return
                        }
                        if let accessToken = headers[HeaderConstant.AuthToken] as? String {
                            self?.tokenStorage.accessToken = accessToken
                        }
                        
                        if let refreshToken = headers[HeaderConstant.RememberMeToken] as? String {
                            self?.tokenStorage.refreshToken = refreshToken
                        }
                        
                        /// must be after accessToken save logic
                        if let accountWarning = headers[HeaderConstant.accountWarning] as? String,
                            accountWarning == HeaderConstant.emptyMSISDN ||
                            accountWarning == HeaderConstant.emptyEmail {
                            sucess?(headers)
                            return
                        } else if let accountStatus = headers[HeaderConstant.accountStatus] as? String,
                            accountStatus.uppercased() == ErrorResponseText.accountDeleted {
                            sucess?(headers)
                            return
                        }
                        
                        if self?.tokenStorage.refreshToken == nil {
                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                            fail?(ErrorResponse.error(error))
                            return
                        }
                        
                        if let statusCode = response.response?.statusCode,
                            statusCode >= 300, statusCode != 403,
                            let data = response.data,
                            let jsonString = String(data: data, encoding: .utf8) {
                            
                            fail?(ErrorResponse.string(jsonString))
                            return
                        }
                        
                        if let statusCode = response.response?.statusCode, statusCode == 403 {
                            
                            SingletonStorage.shared.isTwoFactorAuthEnabled = true

                            guard let data = response.data, let resp = TwoFactorAuthErrorResponse(data: data) else {
                                assertionFailure()
                                return
                            }
                            twoFactorAuth?(resp)
                            return
                        }
                        
                        SingletonStorage.shared.getAccountInfoForUser(success: { _ in
                            CacheManager.shared.actualizeCache()
                            
                            SingletonStorage.shared.isTwoFactorAuthEnabled = false
                            
                            sucess?(headers)
                            MenloworksAppEvents.onLogin()
                        }, fail: { error in
                            fail?(error)
                        })

                    case .failure(let error):
                        fail?(ErrorResponse.error(error))
                    }
        }
    }
    
    func turkcellAutification(user: Authentication3G, sucess: SuccessLogin?, fail: FailResponse?) {
        debugLog("AuthenticationService turkcellAutification")
        
        SessionManager.customDefault.request(user.patch, method: .post, parameters: Device.deviceInfo, encoding: JSONEncoding.prettyPrinted)
            .responseString { [weak self] response in
                self?.loginHandler(response, sucess, fail)
        }
    }
    
    private func loginHandler(_ response: DataResponse<String>, _ sucess: SuccessLogin?, _ fail: FailResponse?) {
        switch response.result {
        case .success(_):
            if let headers = response.response?.allHeaderFields as? [String: Any],
                let accessToken = headers[HeaderConstant.AuthToken] as? String,
                let refreshToken = headers[HeaderConstant.RememberMeToken] as? String {
                self.tokenStorage.accessToken = accessToken
                self.tokenStorage.refreshToken = refreshToken
                SingletonStorage.shared.getAccountInfoForUser(success: { _ in
                    CacheManager.shared.actualizeCache()
                    sucess?()
                }, fail: { error in
                    fail?(error)
                })
            } else {
                let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                fail?(ErrorResponse.error(error))
            }
        case .failure(let error):
            fail?(ErrorResponse.error(error))
        }
    }
    
    // MARK: - Authentication

    func logout(async: Bool = true, success: SuccessLogout?) {
        func logout() {
            debugLog("AuthenticationService logout")
            self.passcodeStorage.clearPasscode()
            self.biometricsManager.isEnabled = false
            self.tokenStorage.clearTokens()
            self.cancellAllRequests()
            
            CellImageManager.clear()
            FreeAppSpace.session.clear()//with session singleton for Free app this one is pointless
            FreeAppSpace.session.handleLogout()
            RecentSearchesService.shared.clearAll()
            SyncServiceManager.shared.stopSync()
            UploadService.default.cancelOperations()
            AutoSyncDataStorage().clear()
            AuthoritySingleton.shared.clear()
            storageVars.autoSyncSet = false
            SingletonStorage.shared.accountInfo = nil
            SingletonStorage.shared.isJustRegistered = nil
            SyncSettings.shared().periodicBackup = SYNCPeriodic.none
            ItemOperationManager.default.clear()
//            ItemsRepository.sharedSession.dropCache()
            ViewSortStorage.shared.resetToDefault()
            AuthoritySingleton.shared.setLoginAlready(isLoginAlready: false)
            
            CardsManager.default.stopAllOperations()
            CardsManager.default.clear()
            
            self.player.stop()
            
            self.storageVars.currentUserID = nil
            
            CacheManager.shared.logout {
                WormholePoster().didLogout()
                success?()
            }
        }
        if async {
            DispatchQueue.main.async {
                logout()
            }   
        } else {
            logout()
        }
    }
    
    func serverLogout(complition: @escaping BoolHandler) {
        let requestParametrs = SigngOutParametes(authToken: self.tokenStorage.accessToken ?? "", rememberMeToken: self.tokenStorage.refreshToken ?? "")
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { response in
            complition(true)
        }, fail: { failresponse in
            complition(false)
        })
        executePostRequest(param: requestParametrs, handler: handler)
    }
    
    func cancellAllRequests() {
        SessionManager.customDefault.cancellAllRequests()
    }
    
    func signUp(user: SignUpUser, handler: @escaping (ErrorResult<SignUpSuccessResponse, Error>) -> Void) {
        debugLog("AuthenticationService signUp")

        guard let params = user.requestParametrs as? Parameters else {
            assertionFailure("wrong signUp parameters")
            handler(.failure(SignupResponseError(status: .networkError)))
            return
        }

        let signUpUrl = RouteRequests.baseUrl +/ RouteRequests.signUp

        sessionManagerWithoutToken
            .request(signUpUrl,
                 method: .post,
                 parameters: params,
                 encoding: JSONEncoding.default,
                 headers: user.header)
            .customValidate()
            .response { response in
                
                guard let httpResponse = response.response else {
                    handler(.failure(response.error ?? SignupResponseError(status: .serverError)))
                    return
                }
                
                if 200...299 ~= httpResponse.statusCode {
                    if let error = response.error as? URLError, error.code == .networkConnectionLost {
                        //case when we received a response with statusCode == 200 and an error "The network connection was lost."
                        handler(.failure(SignupResponseError(status: .networkError)))
                        return
                    }
                    
                    guard let data = response.data else {
                        handler(.failure(response.error ?? SignupResponseError(status: .serverError)))
                        return
                    }
                    
                    let result = SignUpSuccessResponse(withJSON: JSON(data: data))
                    handler(.success(result))
                } else if let data = response.data, let error = SignupResponseError(json: JSON(data: data)) {
                    handler(.failure(error))
                } else if httpResponse.statusCode == 503 {
                    handler(.failure(SignupResponseError(status: .serverErrorUnderMaintenance)))
                } else {
                    handler(.failure(SignupResponseError(status: .serverError)))
                }
            }
    }
    
    func verificationPhoneNumber(phoveVerification: SignUpUserPhoveVerification, sucess: SuccessResponse?, fail: FailResponse?) {
        debugLog("AuthenticationService verificationPhoneNumber")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: phoveVerification, handler: handler)
    }
    
    func resendVerificationSMS(resendVerification: ResendVerificationSMS, sucess: SuccessResponse?, fail: FailResponse?) {
        debugLog("AuthenticationService resendVerificationSMS")
        
        let handler = BaseResponseHandler<SignUpSuccessResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: resendVerification, handler: handler)
    }
    
    func updateEmail(emailUpdateParameters: EmailUpdate, sucess: SuccessResponse?, fail: FailResponse?) {
        debugLog("AuthenticationService updateEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailUpdateParameters, handler: handler)
    }
    
    func verificationEmail(emailVerification: EmailVerification, sucess: SuccessResponse?, fail: FailResponse?) {
        debugLog("AuthenticationService verificationEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailVerification, handler: handler)
    }
    
    func fogotPassword(forgotPassword: ForgotPassword, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("AuthenticationService fogotPassword")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: forgotPassword, handler: handler)
    }

    func turkcellAuth(success: SuccessLogin?, fail: FailResponse?) {
        let user = Authentication3G()
        debugLog("Authentication3G")
        self.turkcellAutification(user: user, sucess: success, fail: { [weak self] error in
            if self?.tokenStorage.refreshToken == nil {
                let error = ErrorResponse.error(error)
                fail?(error)
            } else {
                self?.authorizationSevice.refreshTokens { [weak self] isSuccess, accessToken, _  in
                    if let accessToken = accessToken, isSuccess {
                        self?.tokenStorage.accessToken = accessToken
                        success?()
                    } else {
                        let error = ErrorResponse.error(error)
                        fail?(error)
                    }
                }
            }
        })
    }
    
    
    // MARK: - With new SessionManager
    
    private let sessionManagerWithoutToken: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultCustomHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    func checkEmptyEmail(handler: @escaping ResponseBool) {
        let headers = [HeaderConstant.RememberMeToken: tokenStorage.refreshToken ?? ""]
        let refreshAccessTokenUrl = RouteRequests.baseUrl +/ RouteRequests.authificationByRememberMe
        let params: [String: Any] = Device.deviceInfo//[LbRequestkeys.deviceInfo: Device.deviceInfo]
        
        sessionManagerWithoutToken
            .request(refreshAccessTokenUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .customValidate()
            .responseJSON { response in
                if let headers = response.response?.allHeaderFields as? [String: Any],
                    let warning = headers[HeaderConstant.accountWarning] as? String,
                    warning == HeaderConstant.emptyEmail
                {
                    handler(ResponseResult.success(true))
                } else {
                    handler(ResponseResult.success(false))
                }
        }
    }
    
    func updateUserLanguage(_ language: String, handler: @escaping ResponseVoid) {
        SessionManager.customDefault
            .request(RouteRequests.updateLanguage, method: .post, encoding: language)
            .customValidate()
            .responseVoid(handler)
    }
    
    func silentLogin(token: String, success: SuccessLogin?, fail: FailResponse?) {
        debugLog("AuthenticationService silentLogin")
        
        sessionManagerWithoutToken
            .request(RouteRequests.silentLogin,
                     method: .post,
                     parameters: [LbRequestkeys.token: token,
                                  LbRequestkeys.deviceInfo: Device.deviceInfo],
                     encoding: JSONEncoding.default)
            .responseString { [weak self] response in
                self?.loginHandler(response, success, fail)
        }
    }
    
    func twoFactorAuthChallenge(token: String,
                                authenticatorId: String,
                                type: String,
                                handler: @escaping (ResponseResult<TwoFAChallengeParametersResponse>) -> Void) {
        debugLog("AuthenticationService twoFactorAuthChallenge")
        
        let params: [String: Any] = [
            "token" : token,
            "authenticatorId" : authenticatorId,
            "type" : type,
        ]
        
        SessionManager.customDefault
            .request(RouteRequests.twoFactorAuthChallenge,
                     method: .post,
                      parameters: params,
                     encoding: JSONEncoding.default)
            .responseData { response in
                /// if 401 or 429 server error response.result is success but data contains error
                if response.response?.statusCode == TwoFAErrorCodes.unauthorized.rawValue
                    || response.response?.statusCode == TwoFAErrorCodes.tooManyRequests.rawValue {
                    let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                    handler(.failed(error))
                    return
                }
                
                switch response.result {
                case .success(let data):
                    let model = TwoFAChallengeParametersResponse(json: data, headerResponse: nil)
                    handler(.success(model))
                case .failure(let error):
                    handler(.failed(error))
                }
            }
    }
    
    func loginViaTwoFactorAuth(token: String,
                               challengeType: String,
                               otpCode: String,
                               handler: @escaping (ResponseResult<[String: Any]>) -> Void) {
        debugLog("AuthenticationService loginViaTwoFactorAuth")
        
        let params: [String: Any] = [
            "token"         : token,
            "challengeType" : challengeType,
            "otpCode"       : otpCode,
        ]
        
        sessionManagerWithoutToken
            .request(RouteRequests.twoFactorAuthLogin,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)
                    if let errorType = json["errorType"].string {
                        handler(.failed(ErrorResponse.string(errorType)))
                    } else {
                        guard let headers = response.response?.allHeaderFields as? [String: Any] else {
                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                            handler(.failed(error))
                            return
                        }
                        
                        if let accessToken = headers[HeaderConstant.AuthToken] as? String {
                            self.tokenStorage.accessToken = accessToken
                        }
                        
                        if let refreshToken = headers[HeaderConstant.RememberMeToken] as? String {
                            self.tokenStorage.refreshToken = refreshToken
                        }
                        
                        /// must be after accessToken save logic
                        if let accountWarning = headers[HeaderConstant.accountWarning] as? String,
                            accountWarning == HeaderConstant.emptyMSISDN ||
                            accountWarning == HeaderConstant.emptyEmail {
                            handler(.success(headers))
                            return
                        } else if let accountStatus = headers[HeaderConstant.accountStatus] as? String,
                            accountStatus.uppercased() == ErrorResponseText.accountDeleted {
                            handler(.success(headers))
                            return
                        }
                        
                        guard self.tokenStorage.refreshToken != nil else {
                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                            handler(.failed(error))
                            return
                        }
                        
                        handler(.success(headers))
                    }
                    
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func updateInfoFeedback(isUpdated: Bool, handler: @escaping ResponseVoid) {
        debugLog("AccountService changeFacebookTagsAllowed")
        
        sessionManager
            .request(RouteRequests.Account.updateInfoFeedback,
                     method: .post,
                     encoding: String(isUpdated))
            .customValidate()
            .responseString { response in
                switch response.result {
                case .success(_):
                    handler(.success(()))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
}
