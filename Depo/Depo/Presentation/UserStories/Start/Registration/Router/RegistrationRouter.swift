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
        
        let okHandler: VoidHandler = { [weak self] in
            guard let termsAndServices = self?.router.termsAndServicesScreen(login: false,
                                                                             delegate: delegate,
                                                                             phoneNumber: phoneNumber,
                                                                             signUpResponse: signUpResponse,
                                                                             userInfo: userInfo) else { return }
            self?.router.pushViewController(viewController: termsAndServices)
        }
        
        let message = String(format: TextConstants.registrationEmailPopupMessage, email)
        
        let controller = PopUpController.with(title: TextConstants.registrationEmailPopupTitle,
                                              message: message,
                                              image: .error,
                                              buttonTitle: TextConstants.ok,
                                              action: { vc in
                                                vc.close(completion: okHandler)
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func openSupport() {
        let controller = SupportFormController.with(subjects: [TextConstants.onSignupSupportFormSubject1,
                                                               TextConstants.onSignupSupportFormSubject1,
                                                               TextConstants.onSignupSupportFormSubject1])
        router.pushViewController(viewController: controller)
    }
    
    func goToFaqSupportPage() {
        let faqSupportController = router.helpAndSupport
        router.pushViewController(viewController: faqSupportController)
    }
    
    func gotoSubjectDetailsPage(type: SupportFormSubjectTypeProtocol) {
        let controller = SubjectDetailsViewController.present(with: type)
        router.presentViewController(controller: controller)
    }
}
