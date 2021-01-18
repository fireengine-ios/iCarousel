//
//  LoginLoginRouter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginRouter: LoginRouterInput {
    let router = RouterVC()
    
    func goToForgotPassword() {
        let forgotPassword = router.forgotPasswordScreen
        router.pushViewController(viewController: forgotPassword!)
    }
    
    func goToHomePage() {
        let homePage = router.tabBarScreen
        router.setNavigationController(controller: homePage)
    }
    
    func goToTermsAndServices() {
        let temsAndServices = router.termsAndServicesScreen(login: true, phoneNumber: nil)
        router.pushViewController(viewController: temsAndServices)
    }
    
    func showAccountStatePopUp(image: PopUpImage,
                               title: String,
                               titleDesign: DesignText,
                               message: String,
                               messageDesign: DesignText,
                               buttonTitle: String,
                               buttonAction: @escaping VoidHandler) {
        
        let popUp = CreateStoryPopUp.with(image: image.image,
                                          title: title,
                                          titleDesign: titleDesign,
                                          message: message,
                                          messageDesign: messageDesign,
                                          buttonTitle: buttonTitle,
                                          buttonAction: buttonAction)
        router.presentViewController(controller: popUp, animated: false)
    }
    
    func goToTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse) {
        let vc = TwoFactorAuthenticationViewController(response: response)
        router.pushViewController(viewController: vc)
    }
    
    func showNeedSignUp(message: String, onClose: @escaping VoidHandler) {
        let popUp = PopUpController.with(title: TextConstants.errorAlert,
                                         message: message,
                                         image: .error,
                                         buttonTitle: TextConstants.ok) { controller in
                                            controller.close(completion: onClose)
        }
        router.presentViewController(controller: popUp)
    }
    
    func openSupport() {
        let controller = SupportFormController.with(screenType: .login)
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
}
