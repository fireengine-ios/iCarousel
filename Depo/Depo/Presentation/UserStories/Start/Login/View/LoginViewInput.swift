//
//  LoginLoginViewInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol LoginViewInput: class, Waiting {
        
    func showCaptcha()
    func refreshCaptcha()

    func loginFieldError(_ error: String)
    func passwordFieldError(_ error: String)
    func captchaFieldError(_ error: String)
    
    func showSupportView()
    func showFAQView()
    func showErrorMessage(with text: String)
    
    func hideErrorMessage()
    
    func dehighlightTitles()

    func enterPhoneCountryCode(countryCode: String)
    func insertPhoneCountryCode(countryCode: String) //at the begining of the field
    
    func failedBlockError()

}
