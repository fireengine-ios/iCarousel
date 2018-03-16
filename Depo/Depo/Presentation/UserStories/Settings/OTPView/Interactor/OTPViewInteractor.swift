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
    
    override var remainingTimeInMinutes: Int {
        if let resp = responce {
            return resp.remainingTimeInMinutes ?? 1
        }
        
        return 1
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
        AccountService().verifyPhoneNumber(parameters: parameters, success: {[weak self] responce in
            DispatchQueue.main.async {
                self?.userInfo?.phoneNumber = self?.phoneNumber
                self?.output.verificationSucces()
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
}
