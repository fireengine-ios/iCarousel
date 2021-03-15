//
//  SettingsSettingsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewOutput {

    func viewIsReady()
    
    func onLogout()
    
    func goToHelpAndSupport()
    
    func goToTermsAndPolicy()
    
    func presentErrorMessage(errorMessage: String)
}
