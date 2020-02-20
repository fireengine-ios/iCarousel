//
//  PhoneVerificationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhoneVerificationInteractorOutput: class {
    
    func verificationSucces()
    func verificationFailed(with error: String)
    func verificationSilentSuccess()
    
    func resendCodeRequestFailed(with error: ErrorResponse)
    func resendCodeRequestSucceeded()
    
    func succesLogin()
    func failLogin(message: String)
    func didRedirectToSplash()
    
    func reachedMaxAttempts()
    func loginDeletedAccount(deletedAccountHandler: @escaping VoidHandler)
}
