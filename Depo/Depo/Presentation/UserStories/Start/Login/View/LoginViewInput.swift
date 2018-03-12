//
//  LoginLoginViewInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum LoginViewInputField {
    case login, password
}

protocol LoginViewInput: class, Waiting {
    
    var captchaViewController: CaptchaViewController! { get set }
    
    func setupInitialState(array: [BaseCellModel])
    
    func showCapcha()
    
    func refreshCaptcha()
    
    func showErrorMessage(with text: String)
    func showInfoButton(in field: LoginViewInputField)
    func showNeedSignUp(message: String)
    
    func hideErrorMessage()
    
    func highlightLoginTitle()
    func highlightPasswordTitle()
    func dehighlightTitles()

    func enterPhoneCountryCode(countryCode: String)
    func incertPhoneCountryCode(countryCode: String) //at the begining of the field
    
    func blockUI()
    func unblockUI()
    
    func failedBlockError()
    
}
