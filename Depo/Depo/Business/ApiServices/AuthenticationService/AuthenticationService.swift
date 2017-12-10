//
//  AuthenticationService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias SuccessResponse = (_ value:ObjectFromRequestResponse? ) -> Swift.Void
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
        patch = String(format:patch,rememberMeValue)
        
        return URL(string: patch, relativeTo:super.patch)!
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
                   relativeTo:super.patch)!
    }
}


struct AuthenticationUserByRememberMe: RequestParametrs {
    
    var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.deviceInfo : Device.deviceInfo]
        return dict
    }
    
    var patch: URL {
        return URL(string: RouteRequests.authificationByRememberMe,
                   relativeTo:RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authificationByRememberMe()
    }
}


class AuthenticationUserByToken: BaseRequestParametrs {
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.deviceInfo : Device.deviceInfo]
        return dict
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.authificationByToken,
                   relativeTo:super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}


class SignUpUser: BaseRequestParametrs  {
    
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


struct LogoutUser: RequestParametrs  {
    
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        return URL(string: RouteRequests.logout, relativeTo:RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.logout()
    }
}


struct SignUpUserPhoveVerification: RequestParametrs  {
    
    let token: String
    let otp: String
    
    var requestParametrs: Any {
        let dict: [String: Any] = [LbRequestkeys.referenceToken : token,
                                   LbRequestkeys.otp            : otp]
        return dict
    }
    
    var patch: URL {
        return URL(string: RouteRequests.phoneVerification, relativeTo:RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


struct  ForgotPassword: RequestParametrs {
    let email: String
    let attachedCaptcha: CaptchaParametrAnswer?
    
    
    var requestParametrs: Any {
        return  email.data(using: .utf8) ?? Data()
    }
    
    var patch: URL {
        return URL(string: RouteRequests.forgotPassword, relativeTo:RouteRequests.BaseUrl)!
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
        return URL(string: RouteRequests.mailUpdate, relativeTo:super.patch)!
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
        return URL(string: RouteRequests.mailVerefication, relativeTo:super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


struct ResendVerificationSMS: RequestParametrs {
    let refreshToken: String
    
    var requestParametrs: Any {
        return [LbRequestkeys.referenceToken : refreshToken]
    }
    
    var patch: URL {
        return URL(string: RouteRequests.resendVerificationSMS, relativeTo:RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}


typealias  SuccessLogin = () -> Swift.Void
typealias  SuccessLogout = () -> Swift.Void

typealias  FailLoginType = FailResponse


class AuthenticationService: BaseRequestService {
    
    private var success: SuccessLogin?
    
    private var fail: FailLoginType?
    
    private var successLogin: SuccessResponse!
    
    private var failLogin: FailResponse!
    
    
     override init() {
        super.init()
        
        successLogin = {  [weak self] (succes) in
            guard let data = succes as? LoginResponse else {
                // TODO: GURIN
                return
            }
            ApplicationSession.sharedSession.updateSession(loginData: data)
            self?.success?()
        }
        
        failLogin = { (result) in
            // remove token
            let loginData = LoginResponse(withJSON: nil)
            ApplicationSession.sharedSession.updateSession(loginData: loginData)
            self.fail?(result)
        }
    }
    
    func login(user: AuthenticationUser, sucess:SuccessLogin?, fail: FailResponse?) {
        self.success = sucess
        self.fail = fail
        let handler = BaseResponseHandler<LoginResponse,FailLoginResponse>(success: successLogin, fail: failLogin)
        executePostRequest(param: user, handler: handler)
    }
    
    func autificationByRememberMe(sucess:SuccessLogin?, fail: FailResponse?) {
        let user = AuthenticationUserByRememberMe()
        self.success = sucess
        self.fail = fail
        let handler = BaseResponseHandler<LoginResponse,FailLoginResponse>(success: successLogin, fail: failLogin)
        executePostRequest(param: user, handler: handler)
    }
    
    func autificationByToken(sucess:SuccessLogin?, fail: FailResponse?) {
        let user = AuthenticationUserByToken()
        self.success = sucess
        self.fail = fail
        let handler = BaseResponseHandler<LoginResponse,FailLoginResponse>(success: successLogin, fail: failLogin)
        executePostRequest(param: user, handler: handler)
    }
    
    func turkcellAutification(user: Authentication3G, sucess:SuccessLogin?, fail: FailResponse?) {
        self.success = sucess
        self.fail = fail
        let handler = BaseResponseHandler<LoginResponse,FailLoginResponse>(success: successLogin, fail: fail)
        executePostRequest(param: user, handler: handler)
    }
    
    func logout(success:SuccessLogout?) {
        SingletonStorage.shared().accountInfo = nil
        let successResponse  =  {
            let s = LoginResponse(withJSON: nil)
            /// in LoginResponse(withJSON: nil)
            /// rememberMeToken = ApplicationSession.sharedSession.session.rememberMeToken
            s.rememberMeToken = nil
            ApplicationSession.sharedSession.updateSession(loginData: s)
            success?()
        }
        
        let failResponse: FailResponse = { value in
            let s = LoginResponse(withJSON: nil)
            ApplicationSession.sharedSession.updateSession(loginData: s)
            success?()
        }
        successResponse()
        return
//        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: successResponse, fail: failResponse)
//        executePostRequest(param: param, handler: handler)
    }
    
    func signUp(user: SignUpUser, sucess:SuccessResponse?, fail: FailResponse?) {
        
        let handler = BaseResponseHandler<SignUpSuccessResponse,SignUpFailResponse>(success: sucess, fail: fail)
        executePostRequest(param: user, handler: handler)
    }
    
    func verificationPhoneNumber(phoveVerification: SignUpUserPhoveVerification, sucess:SuccessResponse?, fail:FailResponse?) {
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: phoveVerification, handler: handler)
    }
    
    func resendVerificationSMS(resendVerification: ResendVerificationSMS, sucess:SuccessResponse?, fail:FailResponse?) {
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: resendVerification, handler: handler)
    }
    
    func updateEmail(emailUpdateParameters: EmailUpdate, sucess:SuccessResponse?, fail:FailResponse?) {
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailUpdateParameters, handler: handler)
    }
    
    func verificationEmail(emailVerification:EmailVerification, sucess:SuccessResponse?, fail:FailResponse?) {
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: sucess, fail: fail)
        executePostRequest(param: emailVerification, handler: handler)
    }
    
    func fogotPassword(forgotPassword:ForgotPassword, success:SuccessResponse?, fail: FailResponse?) {
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: forgotPassword, handler: handler)
    }
    
    func authenticate(success:SuccessLogin?, fail: FailResponse?) {
        let reachability = ReachabilityService()
        let rememberMeToken = ApplicationSession.sharedSession.session.rememberMeToken
        if rememberMeToken != nil {
            autificationByRememberMe(sucess: success, fail: fail)
        } else if !reachability.isReachableViaWiFi {
            turkcellAuth(success: success, fail: fail)
        } else {
            autificationByToken(sucess: success, fail: fail)
        }
    }

    private func turkcellAuth(success:SuccessLogin?, fail: FailResponse?) {
        let user = Authentication3G()
        self.turkcellAutification(user: user, sucess: success, fail: { [weak self] error in
            self?.autificationByToken(sucess: success, fail: fail)
        })
    }
}
