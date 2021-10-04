//
//  PhoneVerificationResetPasswordInteractor.swift
//  Depo
//
//  Created by Hady on 9/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol ResetPasswordOTPInteractorOutput: PhoneVerificationInteractorOutput {
    func verified(with resetPasswordService: ResetPasswordService, newMethods: [IdentityVerificationMethod])
}

final class ResetPasswordOTPInteractor {
    private let analyticsService = AnalyticsService()
    private let resetPasswordService: ResetPasswordService
    let phoneNumber: String

    init(resetPasswordService: ResetPasswordService, phoneNumber: String) {
        self.resetPasswordService = resetPasswordService
        self.phoneNumber = phoneNumber

        resetPasswordService.delegate = self
    }

    weak var output: ResetPasswordOTPInteractorOutput!

    var email: String { "" }

    var textDescription: String { TextConstants.enterCodeToGetCodeOnPhone }

    var expectedInputLength: Int?

    var remainingTimeInSeconds: Int = 60

    var attempts: Int = 0

    let MaxAttemps = NumericConstants.maxVerificationAttempts

    private var isVerifying = false

    func resendCode() {
        isVerifying = false

        attempts = 0
        resetPasswordService.sendOTP()
    }

    private func resendCodeFailed(with error: Error) {
        if let errorResponse = error as? ErrorResponse {
            output.resendCodeRequestFailed(with: errorResponse)
        } else {
            output.resendCodeRequestFailed(with: ErrorResponse.error(error))
        }
    }

    func verifyCode(code: String) {
        isVerifying = true

        resetPasswordService.verifyOTP(code: code)
    }

    private func verifyCodeFailed(with error: Error) {
        attempts += 1
        if attempts >= 3 {
            attempts = 0
            output.reachedMaxAttempts()
            output.verificationFailed(with: TextConstants.promocodeBlocked)
        } else {
            output.verificationFailed(with: TextConstants.phoneVerificationNonValidCodeErrorText)
        }
    }
}

extension ResetPasswordOTPInteractor: ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService, receivedOTPResponse response: ResetPasswordResponse) {
        expectedInputLength = response.expectedInputLength
        remainingTimeInSeconds = (response.remainingTimeInMinutes ?? 1) * 60
        output.resendCodeRequestSucceeded()
    }

    func resetPasswordService(_ service: ResetPasswordService,
                              phoneVerified newMethods: [IdentityVerificationMethod]) {
        output.verified(with: resetPasswordService, newMethods: newMethods)

        trackContinueEvent(error: nil)
    }

    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {
        if isVerifying {
            verifyCodeFailed(with: error)

            trackContinueEvent(error: nil)
        } else {
            resendCodeFailed(with: error)
        }
    }
}

extension ResetPasswordOTPInteractor {
    func trackScreen(isTimerExpired: Bool) {
        // TODO: check if sending these is needed too
//        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.OTPSignupScreen())
        analyticsService.logScreen(screen: .signUpOTP)
//        analyticsService.trackDimentionsEveryClickGA(screen: .signUpOTP)
    }

    private func trackContinueEvent(error: Error?) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: .otpSignup,
            eventLabel: .result(error)
        )
    }
}

extension ResetPasswordOTPInteractor: PhoneVerificationInteractorInput {
    func showPopUp(with text: String) {}
    func authificate(atachedCaptcha: CaptchaParametrAnswer?) {}
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate) {}
    func updateEmptyEmail() {}
    func stopUpdatePhone() {}
}
