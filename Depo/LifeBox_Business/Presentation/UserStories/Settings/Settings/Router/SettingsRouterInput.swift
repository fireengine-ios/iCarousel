//
//  SettingsSettingsRouterInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsRouterInput {

    func goToLoginScreen()
    
    func goToPermissions()

    func goToHelpAndSupport()
    
    func goToTermsAndPolicy()
    
    func goToUserInfo(userInfo: AccountInfoResponse)
    
    func goToActivityTimeline()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needReplaceOfCurrentController: Bool)
    
    func closeEnterPasscode()
    
    func openPasscode(handler: @escaping VoidHandler)

    func goToConnectedToNetworkFailed()
    
    func goTurkcellSecurity(isTurkcell: Bool)
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?)
    
    func showError(errorMessage: String)
    
    func presentAlertSheet(alertController: UIAlertController)
    
}
