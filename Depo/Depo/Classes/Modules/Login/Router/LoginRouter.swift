//
//  LoginLoginRouter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginRouter: LoginRouterInput {
    
    func goToForgotPassword(){
        let inicializer = ForgotPasswordModuleInitializer()
        let controller = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        inicializer.forgotpasswordViewController = controller
        inicializer.setupVC()
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(controller, animated: true)
        nController.navigationBar.isHidden = false
    }
    
}
