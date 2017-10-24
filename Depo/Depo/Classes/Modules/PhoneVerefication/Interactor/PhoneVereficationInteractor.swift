//
//  PhoneVereficationPhoneVereficationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationInteractor: PhoneVereficationInteractorInput {    
    
    var dataStorage: PhoneVereficationDataStorage = PhoneVereficationDataStorage()
    
    let authService = AuthenticationService()
    
    weak var output: PhoneVereficationInteractorOutput!
    
//    let customPopUP = CustomPopUp()
    
    var attempts: Int = 0
    
    let MaxAttemps: Int = 3
    
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
        authService.resendVerificationSMS(resendVerification: ResendVerificationSMS(refreshToken: dataStorage.signUpResponse.referenceToken!), sucess: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.output.resendCodeRequestSuccesed()
                
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async { [weak self] in
                self?.output.resendCodeRequestFailed(with: errorResponse)
            }
        })
    }
    
    func verifyCode(code: String) {
        authService.verificationPhoneNumber(phoveVerification: SignUpUserPhoveVerification(token: dataStorage.signUpResponse.referenceToken ?? "", otp: code), sucess:{ [weak self]  _ in
            DispatchQueue.main.async { [weak self] in
                self?.output.verificationSucces()
                
            }
            
        }, fail:{ [weak self] errorRespose in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.attempts += 1
                if self.attempts >= 3 {
                    self.attempts = 0
                    self.output.reachedMaxAttempts()
                }
                self.output.vereficationFailed(with: errorRespose)
            }
        })
    }
    
    func showPopUp(with text: String) {
        CustomPopUp.sharedInstance.showCustomAlert(withText: text, okButtonText: TextConstants.ok)
    }
    
    func authificate(atachedCaptcha: CaptchaParametrAnswer?) {
        
        if (MaxAttemps <= attempts && atachedCaptcha == nil) {
//            output.needShowCaptcha()
            return
        }
        
        let authenticationService = AuthenticationService()
        
        let user = AuthenticationUser(login          : dataStorage.signUpUserInfo.phone,
                                      password       : dataStorage.signUpUserInfo.password,
                                      rememberMe     : true,
                                      attachedCaptcha: atachedCaptcha)
        
        authenticationService.login(user: user, sucess: {
            DispatchQueue.main.async { [weak self] in
                self?.output.succesLogin()
            }
        }, fail: { [weak self] (errorResponse)  in
            
            let incorrectCredentioal = true
            if (incorrectCredentioal) {
                self?.attempts += 1
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.output.failLogin(message: errorResponse.description)
            }
        })
    }
}
