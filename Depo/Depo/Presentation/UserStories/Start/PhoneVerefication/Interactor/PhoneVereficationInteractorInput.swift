//
//  PhoneVereficationPhoneVereficationInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhoneVereficationInteractorInput {
    
    var email: String { get }
    
    var phoneNumber: String { get }
    
    var expectedInputLength: Int? { get }
    
    var remainingTimeInSeconds: Int { get }
    
    func verifyCode(code: String)
    
    func resendCode()
    
    func showPopUp(with text: String)
    
    func authificate(atachedCaptcha: CaptchaParametrAnswer?)
    
    func trackScreen()
    
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate)
    
    func updateEmptyEmail()

    func stopUpdatePhone()
    
}
