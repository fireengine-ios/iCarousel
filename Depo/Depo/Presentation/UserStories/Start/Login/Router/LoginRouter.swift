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
    
    func getCapcha() -> CaptchaViewController {
        let capcha = router.capcha
        return capcha as! CaptchaViewController
    }
    
    func goToTermsAndServices() {
        let temsAndServices = router.termsAndServicesScreen(login: true)
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
}
