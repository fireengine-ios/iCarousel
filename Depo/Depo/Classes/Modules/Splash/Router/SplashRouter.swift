//
//  SplashSplashRouter.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SplashRouter: SplashRouterInput {

    func navigateToApplication(){
        let router = RouterVC()
        let settings = router.tabBarScreen
        router.setNavigationController(controller: settings)
    }
    
    func navigateToOnboarding(){
        let router = RouterVC()
        let settings = router.onboardingScreen
        router.setNavigationController(controller: settings)
    }
    
    func navigateToTermsAndService() {
        let router = RouterVC()
        let temsAndServices = router.termsAndServicesScreen(login: true)
        router.setNavigationController(controller: router.onboardingScreen)
        router.pushViewControllerWithoutAnimation(viewController: temsAndServices)
    }
    
}
