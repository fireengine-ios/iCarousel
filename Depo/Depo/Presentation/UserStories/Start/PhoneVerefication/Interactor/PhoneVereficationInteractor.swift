//
//  PhoneVereficationPhoneVereficationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationInteractor: PhoneVereficationInteractorInput {    
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private let dataStorage: PhoneVereficationDataStorage = PhoneVereficationDataStorage()    
    private lazy var authenticationService = AuthenticationService()
    
    
    weak var output: PhoneVereficationInteractorOutput!
    
    var attempts: Int = 0
    
    let MaxAttemps = NumericConstants.maxVereficationAttempts
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
    }
    
    var remainingTimeInMinutes: Int {
        return dataStorage.signUpResponse.remainingTimeInMinutes ?? 1
    }
    
    var expectedInputLength: Int? {
        return dataStorage.signUpResponse.expectedInputLength
    }
    
    var phoneNumber: String {
        return dataStorage.signUpUserInfo.phone
    }
    
    var email: String {
        return dataStorage.signUpUserInfo.mail
    }
    
    func resendCode() {
        attempts = 0
        authenticationService.resendVerificationSMS(resendVerification: ResendVerificationSMS(refreshToken: dataStorage.signUpResponse.referenceToken!), sucess: { [weak self] _ in
            DispatchQueue.toMain {
                self?.output.resendCodeRequestSuccesed()
                
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.toMain {
                self?.output.resendCodeRequestFailed(with: errorResponse)
            }
        })
    }
    
    func verifyCode(code: String) {
        authenticationService.verificationPhoneNumber(phoveVerification: SignUpUserPhoveVerification(token: dataStorage.signUpResponse.referenceToken ?? "", otp: code, processPersonalData: true), sucess: { [weak self]  _ in
            DispatchQueue.toMain {
                self?.output.verificationSucces()
                
            }
            
        }, fail: { [weak self] errorRespose in
            DispatchQueue.toMain {
                guard let `self` = self else {
                    return
                }
                self.attempts += 1
                if self.attempts >= 3 {
                    self.attempts = 0
                    self.output.reachedMaxAttempts()
                    self.output.vereficationFailed(with: TextConstants.promocodeBlocked)
                } else {
                    self.output.vereficationFailed(with: TextConstants.phoneVereficationNonValidCodeErrorText)
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
            self?.tokenStorage.isRememberMe = true
            self?.analyticsService.track(event: .login)
            DispatchQueue.toMain {
                self?.output.succesLogin()
            }
        }, fail: { [weak self] errorResponse  in
            guard let `self` = self else {
                return
            }
            
            let incorrectCredentioal = true
            if (incorrectCredentioal) {
                self.attempts += 1
            }
            DispatchQueue.toMain {

                if self.isRedirectToSplash(forResponse: errorResponse) {
                    self.output.didRedirectToSplash()
                } else {
                    self.output.failLogin(message: errorResponse.description)
                }
            }
        })
    }
    
    private func isRedirectToSplash(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Captcha required")
    }
}
