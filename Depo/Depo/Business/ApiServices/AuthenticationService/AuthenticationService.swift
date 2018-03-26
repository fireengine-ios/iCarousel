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

typealias SuccessResponse = (_ value: ObjectFromRequestResponse? ) -> Swift.Void
typealias FailResponse = (_ value: ErrorResponse) -> Swift.Void

class AuthenticationUser: BaseRequestParametrs {
    
    let login: String
    let password: String
    let rememberMe: Bool
    let attachedCaptcha: CaptchaParametrAnswer?
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.username   : login,
                                   LbRequestkeys.password   : password,
                                   LbRequestkeys.deviceInfo : Device.deviceInfo]
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
        let patch = String(format: RouteRequests.httpAuthification, LbRequestkeys.on)
        return URL(string: patch,
                   relativeTo: super.patch)!
    }
}

class AuthenticationUserByToken: BaseRequestParametrs {
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.deviceInfo : Device.deviceInfo]
        return dict
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.authificationByToken,
                   relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}


class SignUpUser: BaseRequestParametrs {
    
    let phone: String
    let mail: String
    let password: String
    let eulaId: Int
    
    override var requestParametrs: Any {
        return [
            LbRequestkeys.email: mail,
            LbRequestkeys.phoneNumber: phone,
            LbRequestkeys.password: password,
            LbRequestkeys.language: Device.locale,
            LbRequestkeys.eulaId: eulaId
        ]
    }

    override var patch: URL {
        return URL(string: RouteRequests.signUp, relativeTo: super.patch)!
    }

    init(phone: String, mail: String, password: String, eulaId: Int) {
        self.phone = phone
        self.mail = mail
        self.password = password
        self.eulaId = eulaId
    }
}

struct SignUpUserPhoveVerification: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let token: String
    let otp: String
    
    var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.referenceToken : token,
                                   LbRequestkeys.otp            : otp]
        return dict
    }
    
    var patch: URL {
        return URL(string: RouteRequests.phoneVerification, relativeTo: RouteRequests.BaseUrl)!
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
        return URL(string: RouteRequests.forgotPassword, relativeTo: RouteRequests.BaseUrl)!
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
        return URL(string: RouteRequests.mailVerefication, relativeTo: super.patch)!
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
    
    var requestParametrs: Any {
        return [LbRequestkeys.referenceToken : refreshToken]
    }
    
    var patch: URL {
        return URL(string: RouteRequests.resendVerificationSMS, relativeTo: RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


typealias  SuccessLogin = () -> Swift.Void
typealias  SuccessLogout = () -> Swift.Void
typealias  FailLoginType = FailResponse
typealias  HeadersHandler = ([String: Any]) -> Void

class AuthenticationService: BaseRequestService {
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    // MARK: - Login
    
    func login(user: AuthenticationUser, sucess: HeadersHandler?, fail: FailResponse?) {
        let params: [String: Any] = ["username": user.login,
                                     "password": user.password,
                                     "deviceInfo": Device.deviceInfo]
        
        SessionManager.default.request(user.patch, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: user.attachedCaptcha?.header)
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
                        if let emptyPhoneFlag = headers[HeaderConstant.accountWarning] as? String, emptyPhoneFlag == HeaderConstant.emptyMSISDN {
                            fail?(ErrorResponse.string(HeaderConstant.emptyMSISDN))
                            return
                        }
                        
                        if self?.tokenStorage.refreshToken == nil {
                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
                            fail?(ErrorResponse.error(error))
                            return
                        }

                        sucess?(headers)
                        MenloworksAppEvents.onLogin()
                        
                    case .failure(let error):
                        fail?(ErrorResponse.error(error))
                    }
        }
    }
    
    func autificationByToken(sucess: SuccessLogin?, fail: FailResponse?) {
        let user = AuthenticationUserByToken()
        let params: [String: Any] = ["deviceInfo": Device.deviceInfo]
        
        SessionManager.default.request(user.patch, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted)
            .responseString { [weak self] response in
                self?.loginHandler(response, sucess, fail)
        }
    }
    
    func turkcellAutification(user: Authentication3G, sucess: SuccessLogin?, fail: FailResponse?) {
        SessionManager.default.request(user.patch, method: .post, parameters: Device.deviceInfo, encoding: JSONEncoding.prettyPrinted)
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
                sucess?()
                
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
            self.passcodeStorage.clearPasscode()
            self.biometricsManager.isEnabled = false
            self.tokenStorage.clearTokens()
            CoreDataStack.default.clearDataBase()
            FreeAppSpace.default.clear()
            CardsManager.default.stopAllOperations()
            CardsManager.default.clear()
            RecentSearchesService.shared.clearAll()
            SyncServiceManager.shared.stopSync()
            AutoSyncDataStorage.clear()
            SingletonStorage.shared.accountInfo = nil
            ItemOperationManager.default.clear()
            self.player.stop()
            self.cancellAllRequests()
            
            self.storageVars.currentUserID = nil
            self.storageVars.emptyEmailUp = false
            
            success?()
        }
        if async {
            DispatchQueue.main.async {
                logout()
            }   
        } else {
            logout()
        }
    }
    
    func cancellAllRequests() {
        SessionManager.default.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    func signUp(user: SignUpUser, sucess: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService logout")
        
        let handler = BaseResponseHandler<SignUpSuccessResponse, SignUpFailResponse>(success: { value in
            MenloworksAppEvents.onSignUp()
            sucess?(value)
        }, fail: fail)
        executePostRequest(param: user, handler: handler)
    }
    
    func verificationPhoneNumber(phoveVerification: SignUpUserPhoveVerification, sucess: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService verificationPhoneNumber")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: phoveVerification, handler: handler)
    }
    
    func resendVerificationSMS(resendVerification: ResendVerificationSMS, sucess: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService resendVerificationSMS")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: resendVerification, handler: handler)
    }
    
    func updateEmail(emailUpdateParameters: EmailUpdate, sucess: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService updateEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailUpdateParameters, handler: handler)
    }
    
    func verificationEmail(emailVerification: EmailVerification, sucess: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService verificationEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailVerification, handler: handler)
    }
    
    func fogotPassword(forgotPassword: ForgotPassword, success: SuccessResponse?, fail: FailResponse?) {
        log.debug("AuthenticationService fogotPassword")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: forgotPassword, handler: handler)
    }

    func turkcellAuth(success: SuccessLogin?, fail: FailResponse?) {
        let user = Authentication3G()
        self.turkcellAutification(user: user, sucess: success, fail: { [weak self] error in
            self?.autificationByToken(sucess: success, fail: fail)
        })
    }
}
