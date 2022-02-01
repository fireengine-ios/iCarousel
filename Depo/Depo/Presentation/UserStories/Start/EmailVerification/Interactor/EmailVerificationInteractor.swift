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
    func tooManyRequestsErrorReceievedForMSISDN(error: ServerValueError, signUpResponse: SignUpSuccessResponse)
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
                }
                else if case let .error(underlyingError) = error,
                   let serverValueError = underlyingError as? ServerValueError,
                   serverValueError.value == ServerValueError.ErrorKeys.TOO_MANY_REQUESTS_MSISDN {

                    self.castedOutput.tooManyRequestsErrorReceievedForMSISDN(
                        error: serverValueError,
                        signUpResponse: self.dataStorage.signUpResponse
                    )
                }
                else {
                    self.output.verificationFailed(with: error.localizedDescription)
                    self.analyticsService.trackSignupEvent(error: SignupResponseError(status: .invalidOtp))
                }
            }
        })
    }
}

