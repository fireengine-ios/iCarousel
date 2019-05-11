//
//  LoginLoginRouterInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginRouterInput {
    
    func getEmptyPhoneController() -> TextEnterController?
    
    func getOptInController() -> OptInController?
    
    func renewOptIn(with optIn: OptInController)

    func goToForgotPassword()
    
    func goToHomePage()
    
    func goToTermsAndServices()
    
    func goToSyncSettingsView()
    
    func goToRegistration()

    func openEmptyEmail(successHandler: @escaping VoidHandler)
    
    func openTextEnter(buttonAction: @escaping TextEnterHandler)
    
    func openOptIn(phone: String)

    func showNeedSignUp(message: String, onClose: @escaping VoidHandler)
    
    func openSupport()
}
