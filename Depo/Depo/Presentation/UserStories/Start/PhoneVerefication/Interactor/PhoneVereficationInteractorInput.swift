//
//  PhoneVereficationPhoneVereficationInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhoneVereficationInteractorInput {
    
    func verifyCode(code: String)
    func resendCode()
    
    func showPopUp(with text: String)
    
    func authificate(atachedCaptcha: CaptchaParametrAnswer?)
    
    func trackScreen()
    
    var remainingTimeInSeconds: Int { get }
    
    var expectedInputLength: Int? { get }
    
    var phoneNumber: String { get }
    
    var email: String { get }
}
