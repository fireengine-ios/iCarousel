//
//  PhoneVereficationPhoneVereficationRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhoneVereficationRouterInput {
//    func goToTermAndUses()
    func goAutoSync()
    func presentErrorPopUp(with message: String)
    func showRedirectToSplash()
    
    //TwoFactorAuth
    func popToLogin()
}
