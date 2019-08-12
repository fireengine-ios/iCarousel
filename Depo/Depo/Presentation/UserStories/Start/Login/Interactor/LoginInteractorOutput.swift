//
//  LoginLoginInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginInteractorOutput: class, BaseAsyncOperationInteractorOutput {
    
    func succesLogin()
    
    func processLoginError(_ loginError: LoginResponseError, errorText: String)

    func foundCoutryPhoneCode(code: String, plus: Bool)
    
    func fieldError(type: LoginFieldError)

    func onSuccessEULA()
    func onFailEULA()
    
    func preparedTimePassed(date: Date, forUserName name: String)
    
    func userStillBlocked(user: String)
    func allAttemtsExhausted(user: String)
    
    func updateUserLanguageSuccess()
    func updateUserLanguageFailed(error: Error)
    
    func captchaRequred(requred: Bool)
    func captchaRequredFailed()
    func captchaRequredFailed(with message: String)
    
    func showSupportView()
    func showTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse)
    
    func successedVerifyPhone()
}
