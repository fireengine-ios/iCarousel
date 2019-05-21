//
//  LoginLoginRouterInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginRouterInput {
    
    var optInController: OptInController? { get }
    
    var emptyPhoneController: TextEnterController? { get }
    
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
    
    func dismissEmptyPhoneController(successHandler: @escaping VoidHandler)
}
