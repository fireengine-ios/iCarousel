//
//  ForgotPasswordForgotPasswordInteractor.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class ForgotPasswordInteractor: ForgotPasswordInteractorInput {

    weak var output: ForgotPasswordInteractorOutput!
    private lazy var authenticationService = AuthenticationService()
    private(set) lazy var resetPasswordService = ResetPasswordService()

    var isV2Enabled: Bool {
        return FirebaseRemoteConfig.shared.forgotPasswordV2Enabled
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ForgetPasswordScreen())
    }

    func findCoutryPhoneCode(plus: Bool) {
        let phoneCode = CoreTelephonyService().getColumnedCountryCode()
        output?.foundCoutryPhoneCode(code: phoneCode, plus: plus)
    }

    func sendForgotPasswordRequest(withLogin login: String, enteredCaptcha: String, captchaUDID: String) {
        if isV2Enabled {
            callV2(login: login, enteredCaptcha: enteredCaptcha, captchaUDID: captchaUDID)
        } else {
            callV1(email: login, enteredCaptcha: enteredCaptcha, captchaUDID: captchaUDID)
        }
    }

    private func callV2(login: String, enteredCaptcha: String, captchaUDID: String) {
        let isEmail = Validator.isValid(email: login)
        let isPhone = Validator.isValid(phone: login)
        guard isEmail || isPhone else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: localized(.resetPasswordEnterValidEmail))
            }
            return
        }

        guard !enteredCaptcha.isEmpty else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: localized(.resetPasswordErrorCaptchaFormatText))
            }
            return
        }

        let captcha = CaptchaParametrAnswer(uuid: captchaUDID, answer: enteredCaptcha)
        let params: ForgotPasswordV2
        if isEmail {
            params = ForgotPasswordV2(email: login, msisdn: nil, attachedCaptcha: captcha)
        } else {
            params = ForgotPasswordV2(email: nil, msisdn: login, attachedCaptcha: captcha)
        }

        resetPasswordService.delegate = self
        resetPasswordService.beginResetFlow(with: params)
    }

    private func callV1(email: String, enteredCaptcha: String, captchaUDID: String) {
        guard !email.isEmpty else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: TextConstants.forgotPasswordEmptyEmailText)
            }
            return
        }

        guard Validator.isValid(email: email) else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: TextConstants.forgotPasswordErrorEmailFormatText)
            }
            return
        }

        guard !enteredCaptcha.isEmpty else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: TextConstants.forgotPasswordErrorCaptchaFormatText)
            }
            return
        }

        let captcha = CaptchaParametrAnswer(uuid: captchaUDID, answer: enteredCaptcha)
        let forgotPassword = ForgotPassword(email: email, attachedCaptcha: captcha)
        authenticationService.forgotPassword(forgotPassword: forgotPassword, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output.linkSentToEmailSuccessfully()
            }
        }, fail: { [weak self] response in
            DispatchQueue.main.async {
                let errorMessage = self?.checkErrorService(withErrorResponse: response.description) ?? response.description
                self?.output.requestFailed(withError: errorMessage)
            }
        })
    }

    func checkErrorService(withErrorResponse response: String) -> String? {
        if response == "This package activation code is invalid" {
            return localized(.resetPasswordErrorCaptchaText)
        }
        return nil
    }
}

extension ForgotPasswordInteractor: ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService, resetBeganWithMethods methods: [IdentityVerificationMethod]) {
        output.receivedVerificationMethods(methods)
    }

    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {
        output.requestFailed(withError: error.localizedDescription)
    }
}
