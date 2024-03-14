//
//  PhoneVerificationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import WidgetKit

class PhoneVerificationInteractor: PhoneVerificationInteractorInput {
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    lazy var analyticsService: AnalyticsService = factory.resolve()
    
    let dataStorage: PhoneVerificationDataStorage = PhoneVerificationDataStorage()    
    lazy var authenticationService = AuthenticationService()
    private let cacheManager = CacheManager.shared
    
    weak var output: PhoneVerificationInteractorOutput!

    var initialError: Error?
    
    var attempts: Int = 0
    
    let MaxAttemps = NumericConstants.maxVerificationAttempts
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
    }
    
    func trackScreen(isTimerExpired: Bool) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.OTPSignupScreen())
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

    var title: String {
        return localized(.signUpPhoneVerificationTitle)
    }

    var subTitle: String {
        return localized(.signUpPhoneVerificationSubTitle)
    }
    
    func resendCode() {
        let request = SignUpSendVerification(
            referenceToken: dataStorage.signUpResponse.referenceToken ?? "",
            processPersonalData: true,
            eulaId: dataStorage.signUpResponse.eulaId ?? 0,
            kvkkAuth: dataStorage.signUpResponse.kvkkAuth,
            etkAuth: dataStorage.signUpResponse.etkAuth,
            globalPermAuth: dataStorage.signUpResponse.globalPermAuth ?? false
        )

        attempts = 0
        authenticationService.sendVerification(request: request, success: { [weak self] response in
            DispatchQueue.main.async {
                if let response = response as? SignUpSuccessResponse {
                    self?.dataStorage.signUpResponse.remainingTimeInMinutes = response.remainingTimeInMinutes
                    self?.dataStorage.signUpResponse.expectedInputLength = response.expectedInputLength
                    self?.dataStorage.signUpResponse.referenceToken = response.referenceToken
                }
                self?.output.resendCodeRequestSucceeded()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.output.resendCodeRequestFailed(with: errorResponse)
            }
        })
    }
    
    func startFlow() {
        print()
    }
    
    func verifyCode(code: String) {
        let request = SignUpValidateOTP(referenceToken: dataStorage.signUpResponse.referenceToken ?? "",
                                        otp: code)
        authenticationService.validateOTP(request: request, success: { [weak self] baseResponse in

            if let response = baseResponse as? ObjectRequestResponse,
                let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {

                self?.silentLogin(token: silentToken)
            } else {
                DispatchQueue.main.async {
                    self?.output.verificationSucces()
                }
            }

        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                if case let .error(underlyingError) = error,
                   let serverStatusError = underlyingError as? ServerStatusError,
                   serverStatusError.status == ServerStatusError.ErrorKeys.tooManyInvalidAttempts {
                    self.output.reachedMaxAttempts()
                    self.output.verificationFailed(with: TextConstants.promocodeBlocked)
                    self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .tooManyInvalidOtpAttempts))
                } else {
                    self.output.verificationFailed(with: error.localizedDescription)
                    self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .invalidOtp))
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
            debugLog("Phone Verefication: authificate login successfull")
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            self?.onSuccessLogin()
        }, fail: { [weak self] errorResponse  in
            guard let `self` = self else {
                return
            }
            
            let loginError = LoginResponseError(with: errorResponse)
            
            self.analyticsService.trackLoginEvent(loginType: .rememberLogin, error: loginError)
            self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .serverError))
            
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
        analyticsService.trackSignupEvent()

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
