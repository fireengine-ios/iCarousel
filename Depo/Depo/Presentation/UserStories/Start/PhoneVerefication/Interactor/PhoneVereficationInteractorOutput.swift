//
//  PhoneVereficationPhoneVereficationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhoneVereficationInteractorOutput: class {
    
    func verificationSucces()
    func vereficationFailed(with error: String)
    
    func resendCodeRequestFailed(with error: ErrorResponse)
    func resendCodeRequestSuccesed()
    
    func succesLogin()
    func failLogin(message: String)
    func didRedirectToSplash()
    
    func reachedMaxAttempts()
}
