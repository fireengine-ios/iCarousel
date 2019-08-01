//
//  OTPViewOTPViewInteractor.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewInteractor: PhoneVereficationInteractor {
    
    var responce: SignUpSuccessResponse?
    var userInfo: AccountInfoResponse?
    var phoneNumberString: String?
    
    override var remainingTimeInSeconds: Int {
        if let resp = responce {
            return (resp.remainingTimeInMinutes ?? 1) * 60
        }
        
        return 60
    }
    
    override func trackScreen() {
        analyticsService.logScreen(screen: .doubleOTP)
        analyticsService.trackDimentionsEveryClickGA(screen: .doubleOTP)
    }
    
    override var expectedInputLength: Int? {
        if let resp = responce {
            return resp.expectedInputLength ?? 1
        }
        return nil
    }
    
    override var phoneNumber: String {
        return phoneNumberString ?? ""
    }
    
    override var email: String {
        return userInfo?.email ?? ""
    }
    
    override func verifyCode(code: String) {
        if responce == nil {
            return
        }
        
        let parameters = VerifyPhoneNumberParameter(otp: code, referenceToken: responce!.referenceToken ?? "")
        AccountService().verifyPhoneNumber(parameters: parameters, success: { [weak self] baseResponse in
            DispatchQueue.main.async { [weak self] in
                
                if let response = baseResponse as? ObjectRequestResponse,
                    let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {
                    
                    self?.userInfo?.phoneNumber = self?.phoneNumber
                    self?.silentLogin(token: silentToken)
                } else {
                    self?.verificationSucces()
                }
            }
            
        }) { [weak self] errorRespose in
            DispatchQueue.main.async {
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
        }
    }
    
    override func resendCode() {
        attempts = 0
        
        let parameters = UserPhoneNumberParameters(phoneNumber: phoneNumber)
        AccountService().updateUserPhone(parameters: parameters, success: { [weak self] responce in
                if let responce = responce as? SignUpSuccessResponse {
                    self?.responce = responce
                }
                DispatchQueue.main.async {
                    self?.output.resendCodeRequestSuccesed()
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.resendCodeRequestFailed(with: errorResponse)
                }
        })
    }
    
    private func silentLogin(token: String) {
        authenticationService.silentLogin(token: token, success: { [weak self] in
            self?.savePhoneNumber()
            self?.output.verificationSilentSuccess()
        }, fail: { [weak self] errorResponse in
            self?.verificationSucces()
        })
    }
    
    private func verificationSucces() {
        DispatchQueue.main.async { [weak self] in
            self?.savePhoneNumber()
            self?.output.verificationSucces()
        }
    }
    
    private func savePhoneNumber() {
        userInfo?.phoneNumber = phoneNumber
    }
}
