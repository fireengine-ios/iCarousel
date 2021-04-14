//
//  TwoFactorChallengeRouter.swift
//  Depo
//
//  Created by Raman Harhun on 8/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TwoFactorChallengeRouter: PhoneVerificationRouter {
    
    func goToTermsAndServices() {
        let temsAndServices = router.termsAndServicesScreen(login: true, phoneNumber: nil)
        router.pushViewController(viewController: temsAndServices)
    }
    
    func goToHomePage() {
        let homePage = router.tabBarScreen
        router.setNavigationController(controller: homePage)
    }
}
