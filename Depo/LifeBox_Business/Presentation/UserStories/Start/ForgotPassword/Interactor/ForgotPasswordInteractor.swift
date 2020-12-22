//
//  ForgotPasswordForgotPasswordInteractor.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordInteractor: ForgotPasswordInteractorInput {

    weak var output: ForgotPasswordInteractorOutput!
    private let authenticationService = AuthenticationService()
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ForgetPasswordScreen())
    }
    
    func sendForgotPasswordRequest(with mail: String, enteredCaptcha: String, captchaUDID: String) {
        guard !mail.isEmpty else {
            DispatchQueue.main.async {
                self.output.requestFailed(withError: TextConstants.forgotPasswordEmptyEmailText)
            }
            return
        }
        
        guard Validator.isValid(email: mail) else {
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
        let forgotPassword = ForgotPassword(email: mail, attachedCaptcha: captcha)
        authenticationService.fogotPassword(forgotPassword: forgotPassword, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output.requestSucceed()
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
            return TextConstants.forgotPasswordErrorCaptchaText
        }
        return nil
    }
}
