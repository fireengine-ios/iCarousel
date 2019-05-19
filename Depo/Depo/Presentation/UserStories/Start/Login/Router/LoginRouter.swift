//
//  LoginLoginRouter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginRouter: LoginRouterInput {
    
    let router = RouterVC()
    
    var optInController: OptInController?
    var emptyPhoneController: TextEnterController?
    
    func renewOptIn(with optIn: OptInController) {
        optInController = optIn
    }
    
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
    
    func openTextEnter(buttonAction: @escaping TextEnterHandler) {

        let textEnterVC = TextEnterController.with(title: TextConstants.missingInformation,
                                                   buttonTitle: TextConstants.createStoryPhotosContinue,
                                                   buttonAction: buttonAction)
        let navVC = NavigationController(rootViewController: textEnterVC)
        
        self.emptyPhoneController = textEnterVC

        router.presentViewController(controller: navVC)
    }
    
    func openOptIn(phone: String) {
        let optInController = OptInController.with(phone: phone)
        self.optInController = optInController
        
        router.pushViewController(viewController: optInController)
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
        let controller = router.supportFormController
        router.pushViewController(viewController: controller)
    }
}
