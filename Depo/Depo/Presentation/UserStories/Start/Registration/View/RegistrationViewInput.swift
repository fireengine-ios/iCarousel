//
//  RegistrationRegistrationViewInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationViewInput: RegistrationViewDelegate, Waiting {
    
    func setupInitialState(withModels: [BaseCellModel])
    
    func setupPicker(withModels: [GSMCodeModel])
        
    func setupCurrentGSMCode(toGSMCode gsmCode: String)
    
    func collectInputedUserInfo()
    
    func showInfoButton(forType type: UserValidationResults)
    
    func showErrorTitle(withText: String)
    
    func setupCaptchaVC(captchaVC: CaptchaViewController)
    
    func setScrollViewOffsetForError()
}
