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
    
    func termsAndServices(with delegate: RegistrationViewDelegate?, email: String, phoneNumber: String, signUpResponse: SignUpSuccessResponse? = nil, userInfo: RegistrationUserInfoModel? = nil) {
        let termsAndServices = router.termsAndServicesScreen(login: false,
                                                             delegate: delegate,
                                                             phoneNumber: phoneNumber,
                                                             signUpResponse: signUpResponse,
                                                             userInfo: userInfo)
        router.pushViewController(viewController: termsAndServices)
    }
    
    func openSupport() {
        let controller = SupportFormController.with(screenType: .signup)
        router.pushViewController(viewController: controller)
    }
    
    func goToFaqSupportPage() {
        let faqSupportController = router.faq
        router.pushViewController(viewController: faqSupportController)
    }
    
    func goToSubjectDetailsPage(type: SupportFormSubjectTypeProtocol) {
        let controller = SubjectDetailsViewController.present(with: type)
        router.presentViewController(controller: controller)
    }
}
