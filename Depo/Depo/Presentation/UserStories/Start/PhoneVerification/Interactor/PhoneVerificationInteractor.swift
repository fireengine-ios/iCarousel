//
//  PhoneVerificationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVerificationInteractor: PhoneVerificationInteractorInput {
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private let dataStorage: PhoneVerificationDataStorage = PhoneVerificationDataStorage()    
    lazy var authenticationService = AuthenticationService()
    private let cacheManager = CacheManager.shared
    
    weak var output: PhoneVerificationInteractorOutput!
    
    var attempts: Int = 0
    
    let MaxAttemps = NumericConstants.maxVerificationAttempts
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
    }
    
    func trackScreen(isTimerExpired: Bool) {
        analyticsService.logScreen(screen: .signUpOTP)
        analyticsService.trackDimentionsEveryClickGA(screen: .signUpOTP)
    }
    
    var remainingTimeInSeconds: Int {
        return (dataStorage.signUpResponse.remainingTimeInMinutes ?? 1) * 60
    }
    
    var expectedInputLength: Int? {
        return dataStorage.signUpResponse.expectedInputLength
    }
    
    var phoneNumber: String {
        return dataStorage.signUpUserInfo.phone
    }
    
    var textDescription: String {
        return TextConstants.enterCodeToGetCodeOnPhone
    }
    
    var email: String {
        return dataStorage.signUpUserInfo.mail
    }
    
    func resendCode() {
        let verificationProperties = ResendVerificationSMS(refreshToken: dataStorage.signUpResponse.referenceToken ?? "",
                                                          eulaId: dataStorage.signUpResponse.eulaId ?? 0,
                                                          processPersonalData: true,
                                                          etkAuth: dataStorage.signUpResponse.etkAuth ?? false,
                                                          globalPermAuth: dataStorage.signUpResponse.globalPermAuth ?? false)
        attempts = 0
        authenticationService.resendVerificationSMS(resendVerification: verificationProperties,
                                                    sucess: { [weak self] response in
            DispatchQueue.main.async {
                if let response = response as? SignUpSuccessResponse {
                    self?.dataStorage.signUpResponse.remainingTimeInMinutes = response.remainingTimeInMinutes
                    self?.dataStorage.signUpResponse.expectedInputLength = response.expectedInputLength
                }
                self?.output.resendCodeRequestSucceeded()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.output.resendCodeRequestFailed(with: errorResponse)
            }
        })
    }
    
    func verifyCode(code: String) {
        let signUpProperties = SignUpUserPhoveVerification(token: dataStorage.signUpResponse.referenceToken ?? "",
                                                           otp: code)
        
        authenticationService.verificationPhoneNumber(phoveVerification: signUpProperties, sucess: { [weak self] baseResponse in
            
            if let response = baseResponse as? ObjectRequestResponse,
                let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {
                
                self?.silentLogin(token: silentToken)
            } else {
                DispatchQueue.main.async {
                    self?.output.verificationSucces()
                }
            }
            
        }, fail: { [weak self] errorRespose in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.attempts += 1
                if self.attempts >= 3 {
                    self.attempts = 0
                    self.output.reachedMaxAttempts()
                    self.output.verificationFailed(with: TextConstants.promocodeBlocked)
                } else {
                    self.output.verificationFailed(with: TextConstants.phoneVerificationNonValidCodeErrorText)
                }
            }
        })
    }
    
    func showPopUp(with text: String) {
        UIApplication.showErrorAlert(message: text)
    }
    
    func authificate(atachedCaptcha: CaptchaParametrAnswer?) {
        
        if (MaxAttemps <= attempts && atachedCaptcha == nil) {
//            output.needShowCaptcha()
            return
        }

        let user = AuthenticationUser(login: dataStorage.signUpUserInfo.phone,
                                      password: dataStorage.signUpUserInfo.password,
                                      rememberMe: true,
                                      attachedCaptcha: atachedCaptcha)
        
        authenticationService.login(user: user, sucess: { [weak self] _ in
            self?.onSuccessLogin()
        }, fail: { [weak self] errorResponse  in
            guard let `self` = self else {
                return
            }
            
            let loginError = LoginResponseError(with: errorResponse)
            
            self.analyticsService.trackLoginEvent(loginType: .rememberLogin, error: loginError)
            
            let incorrectCredentioal = true
            if (incorrectCredentioal) {
                self.attempts += 1
            }
            DispatchQueue.main.async {
                if loginError == .incorrectCaptcha || loginError == .needCaptcha {
                    self.output.didRedirectToSplash()
                } else {
                    self.output.failLogin(message: errorResponse.description)
                }
            }
            }, twoFactorAuth: {twoFARequered in
                /// As a result of the meeting, the logic of showing the screen of two factorial authorization is added only with a direct login and is not used with other authorization methods.
                assertionFailure()
                
        })
    }
    
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate) {}
    
    func updateEmptyEmail() {}

    func stopUpdatePhone() {}

    private func isRedirectToSplash(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Captcha required") ||
        errorResponse.description.contains("Invalid captcha")
    }
    
    private func onSuccessLogin() {
        tokenStorage.isRememberMe = true
        analyticsService.track(event: .login)
        analyticsService.trackLoginEvent(loginType: .gsm)
        AuthoritySingleton.shared.setShowPopupAboutPremiumAfterRegistration(isShow: true)
        AuthoritySingleton.shared.setShowPopupAboutPremiumAfterSync(isShow: true)
        
        DispatchQueue.main.async { [weak self] in
            self?.output.succesLogin()
        }
    }
    
    private func silentLogin(token: String) {
        authenticationService.silentLogin(token: token, success: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.onSuccessLogin()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async { [weak self] in
                self?.output.verificationSucces()
            }
        })
    }
    
}
