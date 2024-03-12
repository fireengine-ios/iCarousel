//
//  LoginLoginRouterInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginRouterInput {

    func goToForgotPassword(loginText: String)
    
    func goToHomePage()
    
    func presentEmailVerificationPopUp()
        
    func goToTermsAndServices()
    
    func goToSyncSettingsView()
    
    func goToRegistration()

    func showNeedSignUp(message: String, onClose: @escaping VoidHandler)
    
    func openSupport()
    
    func openEmptyEmail(successHandler: @escaping VoidHandler)
        
    func goToTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse)
    
    func showPhoneVerifiedPopUp(_ onClose: VoidHandler?)
    
    func showAccountStatePopUp(image: PopUpImage,
                               title: String,
                               titleDesign: DesignText,
                               message: String,
                               messageDesign: DesignText,
                               buttonTitle: String,
                               buttonAction: @escaping VoidHandler)
    
    func goToFaqSupportPage()
    
    func goToSubjectDetailsPage(type: SupportFormSubjectTypeProtocol)
    
    func goBack()
}
