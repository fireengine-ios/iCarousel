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
    
    func navigateToLandingPages() {
        let landingVC = LandingPageViewController(nibName: "LandingPageViewController", bundle: nil)
        router.setNavigationController(controller: landingVC)
    }
    
    func navigateToTermsAndService() {
        let temsAndServices = router.termsAndServicesScreen(login: true)
        router.setNavigationController(controller: router.onboardingScreen)
        router.pushViewControllerWithoutAnimation(viewController: temsAndServices)
    }
    
    func showNetworkError() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func goToSyncSettingsView() {
        let settings = router.onboardingScreen
        router.setNavigationController(controller: settings)
        router.pushViewController(viewController: router.synchronyseScreen!)
    }
    
}
