//
//  ForgotPasswordForgotPasswordInteractor.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class ForgotPasswordInteractor: ForgotPasswordInteractorInput {

    weak var output: ForgotPasswordInteractorOutput!
    private(set) lazy var resetPasswordService = ResetPasswordService()
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ForgetPasswordScreen())
    }

    func findCoutryPhoneCode(plus: Bool) {
        let phoneCode = CoreTelephonyService().getColumnedCountryCode()
        output?.foundCoutryPhoneCode(code: phoneCode, plus: plus)
    }

    func sendForgotPasswordRequest(withLogin login: String, enteredCaptcha: String, captchaUDID: String) {
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
        let params: ForgotPassword
        if isEmail {
            params = ForgotPassword(email: login, msisdn: nil, attachedCaptcha: captcha)
        } else {
            params = ForgotPassword(email: nil, msisdn: login, attachedCaptcha: captcha)
        }

        resetPasswordService.delegate = self
        resetPasswordService.beginResetFlow(with: params)
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
