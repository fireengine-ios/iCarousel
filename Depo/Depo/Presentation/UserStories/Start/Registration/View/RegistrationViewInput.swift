//
//  RegistrationRegistrationViewInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationViewInput: RegistrationViewDelegate, Waiting {
        
    func collectInputedUserInfo()
    
    func showInfoButton(forType type: UserValidationResults)
    
    func showErrorTitle(withText: String)
    
    func setupCaptcha()
    
    func updateCaptcha()
    
    func showSupportView()
}
