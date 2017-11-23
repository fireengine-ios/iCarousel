//
//  LoginLoginRouter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginRouter: LoginRouterInput {
    
    func goToForgotPassword(){
        let router = RouterVC()
        let forgotPassword = router.forgotPasswordScreen
        router.pushViewController(viewController: forgotPassword!)
    }
    
    func goToHomePage() {
        let router = RouterVC()
        let homePage = router.tabBarScreen
        router.setNavigationController(controller: homePage)
    }
    
    func getCapcha() -> CaptchaViewController {
        let router = RouterVC()
        let capcha = router.capcha
        return capcha as! CaptchaViewController
    }
    
    func goToTermsAndServices() {
        let router = RouterVC()
        let temsAndServices = router.termsAndServicesScreen(login: true)
        router.pushViewController(viewController: temsAndServices)
    }
    
    func goToSyncSettingsView() {
        let router = RouterVC()
        router.pushViewController(viewController: router.synchronyseScreen!)
    }
    
}
