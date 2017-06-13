//
//  IntroduceIntroduceRouter.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class IntroduceRouter: IntroduceRouterInput {
    
    func onGoToRegister(){
        let inicializer = RegistrationModuleInitializer()
        let registerController = RegistrationViewController(nibName: "RegistrationScreen", bundle:nil)
        inicializer.registrationViewController = registerController
        inicializer.setupVC()
        
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(registerController, animated: true)
        nController.navigationBar.isHidden = false
    }
    
    func onGoToLogin(){
        let inicializer = LoginModuleInitializer()
        let loginController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        inicializer.loginViewController = loginController
        inicializer.setupVC()
        
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(loginController, animated: true)
        nController.navigationBar.isHidden = false
    }
    
}
