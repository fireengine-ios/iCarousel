//
//  SplashSplashRouter.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SplashRouter: SplashRouterInput {

    let router = RouterVC()
    
    func navigateToApplication() {
        let settings = router.tabBarScreen
        router.setNavigationController(controller: settings)
    }
    
    func navigateToOnboarding() {
        let settings = router.onboardingScreen
        router.setNavigationController(controller: settings)
    }
    
    func navigateToLandingPages(isTurkCell: Bool) {
        #if LIFEDRIVE
        let landingVC = LandingPageViewController()
        #else
        let landingVC = LandingPageViewController(isTurkcell: isTurkCell)
        #endif
        router.setNavigationController(controller: landingVC)
    }
    
    func navigateToTermsAndService(isFirstLogin: Bool) {
        let temsAndServices = router.termsAndServicesScreen(login: isFirstLogin, phoneNumber: nil)
        router.setNavigationController(controller: router.onboardingScreen)
        router.pushViewControllerWithoutAnimation(viewController: temsAndServices)
    }
    
    func showNetworkError() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func showError(_ error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
    func goToSyncSettingsView(fromSplash: Bool = false) {
        router.setNavigationController(controller: router.onboardingScreen)
        
        if fromSplash {
            router.pushViewControllerWithoutAnimation(viewController: router.synchronyseScreen)
        } else {
            router.pushViewController(viewController: router.synchronyseScreen)
        }
    }
    
}
