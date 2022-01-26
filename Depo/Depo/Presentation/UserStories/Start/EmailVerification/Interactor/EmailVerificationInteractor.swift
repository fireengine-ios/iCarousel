//
//  EmailVerificationInteractor.swift
//  Depo
//
//  Created by Hady on 1/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol EmailVerificationInteractorOutput: PhoneVerificationInteractorOutput {
    func emailVerified(signUpResponse: SignUpSuccessResponse)
}

final class EmailVerificationInteractor: PhoneVerificationInteractor {

    var castedOutput: EmailVerificationInteractorOutput {
        return output as! EmailVerificationInteractorOutput
    }

    override func trackScreen(isTimerExpired: Bool) {

    }

    override var textDescription: String {
        return localized(.signUpEnterVerificationCodeEmail)
    }

    override func verifyCode(code: String) {
        let request = SignUpValidateOTP(referenceToken: dataStorage.signUpResponse.referenceToken ?? "",
                                        otp: code)
        authenticationService.validateOTP(request: request, success: { [weak self] baseResponse in

            if let response = baseResponse as? SignUpSuccessResponse {
                self?.castedOutput.emailVerified(signUpResponse: response)
            } else {
                debugLog("ERROR: email verification")
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
                    self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .tooManyInvalidOtpAttempts))
                } else {
                    self.output.verificationFailed(with: TextConstants.phoneVerificationNonValidCodeErrorText)
                    self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .invalidOtp))
                }
            }
        })
    }
}

