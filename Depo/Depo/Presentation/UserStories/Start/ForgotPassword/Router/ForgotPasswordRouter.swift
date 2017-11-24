//
//  ForgotPasswordForgotPasswordRouter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordRouter: ForgotPasswordRouterInput {
   
    func goToResetPassword() {
        
    }
    
    func popBack() {//Goes to Login
        let router = RouterVC()
        let navVC = router.navigationController//rootViewController
        navVC?.popViewController(animated: true)
//        let navVC = UINavigationController(rootViewController: router.loginScreen!)
//        navVC.navigationBar.isHidden = true
//        router.setNavigationController(controller: navVC)
    }
}
