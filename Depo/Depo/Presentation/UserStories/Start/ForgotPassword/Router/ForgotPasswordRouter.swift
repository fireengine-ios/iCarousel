//
//  ForgotPasswordForgotPasswordRouter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ForgotPasswordRouter: ForgotPasswordRouterInput {
   
    func goToResetPassword() {
        let vc = PopUpController.with(title: TextConstants.success,
                                      message: TextConstants.forgotPasswordSentEmailAddres,
                                      image: .error,
                                      buttonTitle: TextConstants.ok,
                                      action: { vc in
                                        vc.dismiss(animated: true, completion: { [weak self] in
                                            self?.popBack()
                                        })
        })
        
        RouterVC().presentViewController(controller: vc)
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
