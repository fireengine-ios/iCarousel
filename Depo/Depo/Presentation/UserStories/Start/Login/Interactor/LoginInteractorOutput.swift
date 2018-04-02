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
    
    func failLogin(message: String)
    
    func needSignUp(message: String)
    
    func models(models: [BaseCellModel])
    
    func needShowCaptcha()
    func failedBlockError()
    
    func foundCoutryPhoneCode(code: String, plus: Bool)
    
    func loginFieldIsEmpty()
    func passwordFieldIsEmpty()
    
    func onSuccessEULA()
    func onFailEULA()
    
    func allAttemtsExhausted(user: String)
    
    func preparedTimePassed(date: Date, forUserName name: String)
    
    func userStillBlocked(user: String)
    
    func openEmptyPhone()
    
    func successed(tokenUpdatePhone: SignUpSuccessResponse)
    func failedUpdatePhone(errorResponse: ErrorResponse)
    
    func successed(resendUpdatePhone: SignUpSuccessResponse)
    func failedResendUpdatePhone(errorResponse: ErrorResponse)
    
    func successedVerifyPhone()
    func failedVerifyPhone(errorString: String)
    
    func updateUserLanguageSuccess()
    func updateUserLanguageFailed(error: Error)
}
