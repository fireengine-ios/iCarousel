//
//  LoginLoginRouterInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginRouterInput {

    func goToForgotPassword()
    
    func goToHomePage()
    
    func getCapcha() -> CaptchaViewController?
    
    func goToTermsAndServices()
    
    func goToSyncSettingsView()
    
    func goToRegistration()

}
