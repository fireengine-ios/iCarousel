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
            image: .custom(Image.forgetPassPopupLock.image), buttonTitle: TextConstants.ok) { vc in

            vc.close { [weak self] in
                self?.popBack()
            }
        }
        
        vc.open()

    }
    
    func receivedOTPVerification(service: ResetPasswordService, availableMethods: [IdentityVerificationMethod]) {
        let viewController = ResetPasswordOTPModuleInitializer.viewController(resetPasswordService: service, phoneNumber: service.msisdn ?? "")
        RouterVC().replaceTopViewControllerWithViewController(viewController)
    }

    func proceedToIdentityVerification(service: ResetPasswordService,
                                       availableMethods: [IdentityVerificationMethod]) {
        let viewController = IdentityVerificationViewController(resetPasswordService: service,
                                                                availableMethods: availableMethods)
        RouterVC().replaceTopViewControllerWithViewController(viewController)
    }
    
    func popBack() {//Goes to Login
        let router = RouterVC()
        let navVC = router.navigationController
        navVC?.popViewController(animated: true)
    }
}
