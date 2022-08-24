//
//  ForgotPasswordForgotPasswordRouter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordRouter: ForgotPasswordRouterInput {
   
    func showSentToEmailPopupAndClose() {
        let vc = PopUpController.with(
            title: TextConstants.success, message: TextConstants.forgotPasswordSentEmailAddres,
            image: .error, buttonTitle: TextConstants.ok) { vc in

            vc.close { [weak self] in
                self?.popBack()
            }
        }
        
        vc.open()

    }

    func proceedToIdentityVerification(service: ResetPasswordService,
                                       availableMethods: [IdentityVerificationMethod]) {
        let viewController = IdentityVerificationViewController(resetPasswordService: service,
                                                                availableMethods: availableMethods)
        RouterVC().replaceTopViewControllerWithViewController(viewController)
    }
    
    func popBack() {//Goes to Login
        let router = RouterVC()
        let navVC = router.navigationController//rootViewController
        navVC?.popViewController(animated: true)
//        let navVC = UINavigationController(rootViewController: router.loginScreen!)
//        navVC.navigationBar.isHidden = true
//        router.setNavigationController(controller: navVC)
    }
}
