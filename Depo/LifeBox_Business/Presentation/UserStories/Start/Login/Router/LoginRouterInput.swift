//
//  LoginLoginRouterInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginRouterInput {
    
    func goToHomePage()
    
    func goToTermsAndServices()
    
    func openSupport()
        
    func goToTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse, rememberMe: Bool)
    
    func showAccountStatePopUp(image: PopUpImage,
                               title: String,
                               titleDesign: DesignText,
                               message: String,
                               messageDesign: DesignText,
                               buttonTitle: String,
                               buttonAction: @escaping VoidHandler)
    
    func goToFaqSupportPage()
    
    func goToSubjectDetailsPage(type: SupportFormSubjectTypeProtocol)
}
