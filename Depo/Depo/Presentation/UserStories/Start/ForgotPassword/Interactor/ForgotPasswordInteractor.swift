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
        authenticationService.fogotPassword(forgotPassword: ForgotPassword(email: mail, attachedCaptcha: CaptchaParametrAnswer(uuid: captchaUDID, answer: enteredCaptcha)),
                                            success: { [weak self] _ in
            DispatchQueue.main.async {
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
        if let response1 = response as? String, response1.description.contains("4001") {
            return "Please enter captcha."
        }
        return "Error Handling Under Constraction"
    }
    
}
