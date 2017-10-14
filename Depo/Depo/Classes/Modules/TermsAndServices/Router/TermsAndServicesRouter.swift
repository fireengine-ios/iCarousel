//
//  TermsAndServicesTermsAndServicesRouter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesRouter: TermsAndServicesRouterInput {
    
    let routerVC = RouterVC()
    
    func goToAutoSync(){
        routerVC.pushViewController(viewController: routerVC.synchronyseScreen!)
    }
    
    func goToHomePage() {
        routerVC.setNavigationController(controller: routerVC.homePageScreen)
    }
    
    func goToPhoneVerefication(withSignUpSuccessResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        routerVC.pushViewController(viewController: routerVC.phoneVereficationScreen(withSignUpSuccessResponse: withSignUpSuccessResponse, userInfo: userInfo))
    }
    
    func closeModule() {
        routerVC.popViewController()
    }
}
