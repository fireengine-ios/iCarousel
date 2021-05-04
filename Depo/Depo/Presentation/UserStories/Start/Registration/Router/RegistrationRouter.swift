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
    
    func phoneVerification(sigUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        let phoneVerification = router.phoneVerificationScreen(withSignUpSuccessResponse: sigUpResponse, userInfo: userInfo)
        router.pushViewController(viewController: phoneVerification)
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
}
