//
//  SettingsSettingsRouter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SettingsRouter: SettingsRouterInput {
    
    let router = RouterVC()

    func navigateToAgreements() {
        // TODO when ready- add routing to agreements screen
    }

    func navigateToProfile() {
        // TODO when ready- add routing to profile screen
    }

    func navigateToFAQ() {
        // TODO when ready- add routing to FAQ
    }

    func navigateToContactUs() {
        let controller = ContactUsViewController.initFromNib()
        router.pushViewController(viewController: controller)
    }

    func navigateToTrashBin() {
        // TODO when ready- add routing to trash bin screen
    }
    
    func goToLoginScreen() {
        let navC = UINavigationController(rootViewController: router.loginScreen!)
        router.setNavigationController(controller: navC)
    }

    func goToConnectedToNetworkFailed() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func showMailUpdatePopUp(delegate: MailVerificationViewControllerDelegate?) {
        let mailController = MailVerificationViewController()
        mailController.actionDelegate = delegate
        mailController.modalPresentationStyle = .overFullScreen
        mailController.modalTransitionStyle = .crossDissolve
        router.presentViewController(controller: mailController)//.present(mailController, animated: true, completion: nil)
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func presentAlertSheet(alertController: UIAlertController) {
        router.presentViewController(controller: alertController)
    }
}
