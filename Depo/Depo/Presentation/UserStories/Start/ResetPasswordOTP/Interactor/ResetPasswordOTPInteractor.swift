//
//  PhoneVerificationResetPasswordInteractor.swift
//  Depo
//
//  Created by Hady on 9/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol ResetPasswordOTPInteractorInput: PhoneVerificationInteractorInput {
    func trackBackEvent()
}

protocol ResetPasswordOTPInteractorOutput: PhoneVerificationInteractorOutput {
    func verified(with resetPasswordService: ResetPasswordService, newMethods: [IdentityVerificationMethod])
}

final class ResetPasswordOTPInteractor {
    private let analyticsService = AnalyticsService()
    private let resetPasswordService: ResetPasswordService
    private var referenceToken: String = ""
    let phoneNumber: String
    

    init(resetPasswordService: ResetPasswordService, phoneNumber: String) {
        self.resetPasswordService = resetPasswordService
        self.phoneNumber = phoneNumber
        self.referenceToken = resetPasswordService.referenceToken ?? ""
        resetPasswordService.delegate = self
    }

    weak var output: ResetPasswordOTPInteractorOutput!

    var email: String { "" }

    var textDescription: String { TextConstants.enterCodeToGetCodeOnPhone }

    var title: String { TextConstants.enterSecurityCode }

    var subTitle: String { TextConstants.enterSecurityCode }

    var expectedInputLength: Int?

    var remainingTimeInSeconds: Int = 60

    var attempts: Int = 0

    let MaxAttemps = NumericConstants.maxVerificationAttempts

    private var isVerifying = false
    
    func startFlow() {
        isVerifying = false
        attempts = 0
        remainingTimeInSeconds = 180
        output.resendCodeRequestSucceeded()
    }

    func resendCode() {
        isVerifying = false
        attempts = 0
        resetPasswordService.sendOTPV2()
        output.resendCodeRequestSucceeded()
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
        resetPasswordService.verifyOTP(referenceToken: referenceToken, code: code)
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
        remainingTimeInSeconds = 180
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
            
            trackContinueEvent(error: error)
        } else {
            resendCodeFailed(with: error)
        }
    }
}

extension ResetPasswordOTPInteractor {
    func trackScreen(isTimerExpired: Bool) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.FPOtpScreen())
        analyticsService.logScreen(screen: .resetPasswordOTP)
    }

    func trackBackEvent() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.FPOtpBack())
    }

    private func trackContinueEvent(error: Error?) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: .otpResetPassword,
            eventLabel: .result(error)
        )

        let status: NetmeraEventValues.GeneralStatus = error == nil ? .success : .failure
        AnalyticsService.sendNetmeraEvent(
            event: NetmeraEvents.Actions.FPOtp(status: status)
        )
    }
}

extension ResetPasswordOTPInteractor: ResetPasswordOTPInteractorInput {
    var initialError: Error? { nil }
    func showPopUp(with text: String) {}
    func authificate(atachedCaptcha: CaptchaParametrAnswer?) {}
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate) {}
    func updateEmptyEmail() {}
    func stopUpdatePhone() {}
}
