//
//  OTPViewOTPViewInteractor.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewInteractor: PhoneVerificationInteractor {
    
    private var response: SignUpSuccessResponse?
    private var userInfo: AccountInfoResponse?
    private var phoneNumberString: String?
    
    
    required init(userInfo: AccountInfoResponse, phoneNumber: String, response: SignUpSuccessResponse) {
        self.response = response
        self.userInfo = userInfo
        self.phoneNumberString = phoneNumber
    }
    
    override var remainingTimeInSeconds: Int {
        if let resp = response {
            return (resp.remainingTimeInMinutes ?? 1) * 60
        }
        
        return 60
    }
    
    override func trackScreen(isTimerExpired: Bool) {
        analyticsService.logScreen(screen: .doubleOTP)
        analyticsService.trackDimentionsEveryClickGA(screen: .doubleOTP)
    }
    
    override var expectedInputLength: Int? {
        if let resp = response {
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
        guard let response = response else {
            assertionFailure("Response doesn't exist")
            return
        }
        
        let parameters = VerifyPhoneNumberParameter(otp: code, referenceToken: response.referenceToken ?? "")
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
                    self.response = nil
                    self.output.reachedMaxAttempts()
                    self.output.verificationFailed(with: TextConstants.promocodeBlocked)
                } else {
                    self.output.verificationFailed(with: TextConstants.phoneVerificationNonValidCodeErrorText)
                }
            }
        }
    }
    
    override func resendCode() {
        attempts = 0
        
        let numberUpdateIsCalled = (response != nil)
        
        if numberUpdateIsCalled {
            confirmPhoneNumberUdpate()
        } else {
            updatePhoneNumberBeforeOTP()
        }
    }
    
    private func updatePhoneNumberBeforeOTP() {
        let parameters = UserPhoneNumberParameters(phoneNumber: phoneNumber)
        AccountService().updateUserPhone(parameters: parameters, success: { [weak self] response in
                if let response = response as? SignUpSuccessResponse {
                    self?.response = response
                }
                DispatchQueue.main.async {
                    self?.output.resendCodeRequestSucceeded()
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.resendCodeRequestFailed(with: errorResponse)
                }
        })
    }
    
    /**
     * Call if updateUserPhone is already called
     */
    private func confirmPhoneNumberUdpate() {
        guard response != nil else {
            assertionFailure("Call if updateUserPhone is already called")
            return
        }
        
        DispatchQueue.toMain {
            self.output.resendCodeRequestSucceeded()
        }
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
