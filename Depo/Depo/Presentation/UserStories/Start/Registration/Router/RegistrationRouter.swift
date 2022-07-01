//
//  RegistrationRegistrationRouter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationRouter: RegistrationRouterInput {
    let router = RouterVC()

    func presentEmailUsagePopUp(email: String, onClosed: @escaping () -> Void) {
        let message = String(format: TextConstants.registrationEmailPopupMessage, email)

        let controller = PopUpController.with(
            title: TextConstants.registrationEmailPopupTitle,
            message: message,
            image: .error,
            buttonTitle: TextConstants.ok,
            action: { vc in
                vc.close {
                    onClosed()
                }
            })

        controller.open()
    }

    func phoneVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        let phoneVerification = router.phoneVerificationScreen(signUpResponse: signUpResponse, userInfo: userInfo)
        router.pushViewController(viewController: phoneVerification)
    }

    func emailVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        let emailVerification = router.emailVerificationScreen(signUpResponse: signUpResponse, userInfo: userInfo)
        router.pushViewController(viewController: emailVerification)
    }

    func openSupport() {
        let controller = SupportFormController.with(screenType: .signup)
        router.pushViewController(viewController: controller)
    }

    func goToFaqSupportPage() {
        let faqSupportController = router.helpAndSupport
        router.pushViewController(viewController: faqSupportController)
    }
    
    func goToSubjectDetailsPage(type: SupportFormSubjectTypeProtocol) {
        let controller = SubjectDetailsViewController.present(with: type)
        router.presentViewController(controller: controller)
    }

    func goToPrivacyPolicyDescriptionController() {
        let viewController = PrivacyPolicyController()
        router.pushViewController(viewController: viewController)
    }
    
    func goBack() {
        router.popViewController()
    }
}
