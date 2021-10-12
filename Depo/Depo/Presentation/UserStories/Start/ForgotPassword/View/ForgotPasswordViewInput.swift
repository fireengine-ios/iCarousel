//
//  ForgotPasswordForgotPasswordViewInput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ForgotPasswordViewInput: AnyObject, Waiting {
    
    func setupInitialState()
    
    func showCapcha()

    func setTexts(_ texts: ForgotPasswordTexts)

    func enterPhoneCountryCode(countryCode: String)
    func insertPhoneCountryCode(countryCode: String) //at the begining of the field
}

struct ForgotPasswordTexts {
    let instructions: String
    let instructionsOther: String
    let emailInputTitle: String
    let emailPlaceholder: String
}
