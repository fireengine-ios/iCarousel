//
//  OTPViewOTPViewInteractor.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewInteractor: PhoneVereficationInteractor {
    
    var responce: SignUpSuccessResponse? = nil
    var userInfo: AccountInfoResponse? = nil
    
    override var remainingTimeInMinutes: Int {
        if let resp = responce{
            return resp.remainingTimeInMinutes ?? 1
        }
        
        return 1
    }
    
    override var expectedInputLength: Int? {
        if let resp = responce{
            return resp.expectedInputLength ?? 1
        }
        return nil
    }
    
    override var phoneNumber: String {
        if let info = userInfo{
            return info.phoneNumber ?? ""
        }
        
        return ""
    }
    
    override var email: String {
        if let info = userInfo{
            return info.email ?? ""
        }
        
        return ""
    }
    
    override func verifyCode(code: String) {
        if responce == nil {
            return
        }
        
        let parameters = VerifyPhoneNumberParameter(otp: code, referenceToken: responce!.referenceToken ?? "")
        AccountService().verifyPhoneNumber(parameters: parameters, success: { (responce) in
            DispatchQueue.main.async { [weak self] in
                self?.output.verificationSucces()
            }
        }) { (errorRespose) in
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
        }
    }
    
    override func resendCode() {
        guard let referenceToken = responce?.referenceToken else {
            return
        }
        authService.resendVerificationSMS(resendVerification: ResendVerificationSMS(refreshToken: referenceToken), sucess: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.output.resendCodeRequestSuccesed()
                
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async { [weak self] in
                    self?.output.resendCodeRequestFailed(with: errorResponse)
                }
        })
    }
    
}
