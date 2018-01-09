//
//  ForgotPasswordForgotPasswordInteractor.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordInteractor: ForgotPasswordInteractorInput {

    weak var output: ForgotPasswordInteractorOutput!

    func sendForgotPasswordRequest(with mail: String, enteredCaptcha: String, captchaUDID: String) {
        let authenticationService = AuthenticationService()
        authenticationService.fogotPassword(forgotPassword: ForgotPassword(email: mail, attachedCaptcha: CaptchaParametrAnswer(uuid: captchaUDID, answer: enteredCaptcha)), success: { _ in
            DispatchQueue.main.async { [weak self] in
                self?.output.requestSucceed()
            }
            }, fail: { response in
                DispatchQueue.main.async { [weak self] in
                    debugPrint("forgot password response fail", response.description)
                    self?.output.requestFailed(withError: self?.checkErrorService(withErrorResponse: response.description) ?? "Error")
                }
        })
    }
    
    func checkErrorService(withErrorResponse response: Any) -> String {
        guard let response1 = response as? String else {
            return "Error Handling Under Constraction"
        }
        
        if response1.contains("ACCOUNT_NOT_FOUND_FOR_EMAIL") {
            return "Account not found for email"
        }
        if response1 == "This package activation code is invalid" {
            return "This text doesn't match. Please try again"
        }
        return "An error is occurred!"
    }
    
}
