//
//  IntroduceIntroduceRouter.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class IntroduceRouter: IntroduceRouterInput {
    
    func onGoToRegister() {
        let router = RouterVC()
        let register = router.registrationScreen
        router.pushViewController(viewController: register!)
    }
    
    func onGoToLogin() {
        let router = RouterVC()
        let loginScreen = router.loginScreen
        
        router.pushViewController(viewController: loginScreen!)
    }
    
    func onGoToRegister(with user: GoogleUser) {
        let router = RouterVC()
        let registerScreen = router.registerWithGoogle(user: user)
        
        router.pushViewController(viewController: registerScreen)
    }
    
    func onGoToLoginWith(with user: GoogleUser) {
        let router = RouterVC()
        let loginScreen = router.loginWithGoogle(user: user)
        
        router.pushViewController(viewController: loginScreen)
    }
}
