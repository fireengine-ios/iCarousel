//
//  SettingsSettingsRouterInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SettingsRouterInput {

    func navigateToFAQ()

    func navigateToProfile()

    func navigateToAgreements()

    func navigateToTrashBin()
    
    func navigateToContactUs()

    func goToLoginScreen()

    func goToConnectedToNetworkFailed()
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?)
    
    func showError(errorMessage: String)
    
    func presentAlertSheet(alertController: UIAlertController)
    
}
