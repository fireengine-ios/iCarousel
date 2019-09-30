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
    
    func goToSyncSettingsView() {
        router.pushViewController(viewController: router.synchronyseScreen)
    }
    
    func goToRegistration() {
        if let registrationScreen = router.registrationScreen {
            router.pushViewController(viewController: registrationScreen)
        }
    }
    
    func openEmptyEmail(successHandler: @escaping VoidHandler) {
        let vc = EmailEnterController.initFromNib()
        vc.successHandler = successHandler
        let navVC = NavigationController(rootViewController: vc)
        router.presentViewController(controller: navVC)
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
        let controller = SupportFormController.with(subjects: [TextConstants.supportFormSubject1,
                                                               TextConstants.supportFormSubject2,
                                                               TextConstants.supportFormSubject3,
                                                               TextConstants.supportFormSubject4,
                                                               TextConstants.supportFormSubject5,
                                                               TextConstants.supportFormSubject6,
                                                               TextConstants.supportFormSubject7])
        router.pushViewController(viewController: controller)
    }
    
    func showPhoneVerifiedPopUp(_ onClose: VoidHandler?) {
        let popupVC = PopUpController.with(title: nil,
                                           message: TextConstants.phoneUpdatedNeedsLogin,
                                           image: .none,
                                           buttonTitle: TextConstants.ok) { vc in
                                            vc.close {
                                                onClose?()
                                            }
        }
        
        UIApplication.topController()?.present(popupVC, animated: false, completion: nil)
    }
    
    func goToFaqSupportPage() {
        let faqSupportController = router.helpAndSupport
        router.pushViewController(viewController: faqSupportController)
    }
    
    func gotoSubjectDetailsPage(type: SupportFormSubjectType) {
        let controller = SubjectDetailsViewController.present(with: type)
        router.presentViewController(controller: controller)
    }
}
