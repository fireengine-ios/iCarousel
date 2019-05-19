//
//  RegistrationRegistrationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationViewOutput {
    
    var isSupportFormPresenting: Bool { get set }
    
    func viewIsReady()
    
    func prepareCaptcha(_ view: CaptchaView)
    
    func nextButtonPressed()
    
    func collectedUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?)
    
    func captchaRequred(requred: Bool)
    
    func openSupport()
}
