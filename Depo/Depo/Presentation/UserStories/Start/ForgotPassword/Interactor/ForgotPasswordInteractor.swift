//
//  ForgotPasswordForgotPasswordInteractor.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordInteractor: ForgotPasswordInteractorInput {

    weak var output: ForgotPasswordInteractorOutput!
    let authenticationService = AuthenticationService()
    
    func sendForgotPasswordRequest(with mail: String, enteredCaptcha: String, captchaUDID: String) {
        guard !mail.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.output.requestFailed(withError: TextConstants.forgotPasswordEmptyEmailText)
            }
            return
        }
        
        guard isValid(email: mail) else {
            DispatchQueue.main.async { [weak self] in
                self?.output.requestFailed(withError: TextConstants.forgotPasswordErrorEmailFormatText)
            }
            return
        }
        
        guard !enteredCaptcha.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.output.requestFailed(withError: TextConstants.forgotPasswordErrorCaptchaFormatText)
            }
            return
        }
        
        let authenticationService = AuthenticationService()
        authenticationService.fogotPassword(forgotPassword: ForgotPassword(email: mail, attachedCaptcha: CaptchaParametrAnswer(uuid: captchaUDID, answer: enteredCaptcha)), success: { _ in
            DispatchQueue.main.async { [weak self] in
                self?.output.requestSucceed()
            }
        }, fail: { [weak self] response in
            DispatchQueue.main.async {
                debugPrint("forgot password response fail", response.description)
                self?.output.requestFailed(withError: self?.checkErrorService(withErrorResponse: response.description) ?? "Error")
            }
        })
    }
    
    func checkErrorService(withErrorResponse response: Any) -> String {
        guard let response1 = response as? String else {
            return TextConstants.forgotPasswordErrorHandlingText
        }
        
        if response1.contains("ACCOUNT_NOT_FOUND_FOR_EMAIL") {
            return TextConstants.forgotPasswordErrorEmailNotFoundText
        }
        if response1 == "This package activation code is invalid" {
            return TextConstants.forgotPasswordErrorCaptchaText
        }
        return TextConstants.forgotPasswordCommonErrorText
    }
    
    fileprivate func isValid(email: String) -> Bool {
        let emailRegEx = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
}
