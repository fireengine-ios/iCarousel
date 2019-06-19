//
//  TermsAndServicesTermsAndServicesRouter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesRouter: TermsAndServicesRouterInput {
    
    let routerVC = RouterVC()
    
    func goToAutoSync() {
        routerVC.pushViewController(viewController: routerVC.synchronyseScreen)
    }
    
    func goToHomePage() {
        routerVC.setNavigationController(controller: routerVC.tabBarScreen)
    }
    
    func goToPhoneVerefication(withSignUpSuccessResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        routerVC.pushViewController(viewController: routerVC.phoneVereficationScreen(withSignUpSuccessResponse: withSignUpSuccessResponse, userInfo: userInfo))
    }
    
    func closeModule() {
        routerVC.popViewController()
    }
    
    func goToTurkcellAndGroupCompanies() {
        let vc = WebViewController(urlString: RouteRequests.turkcellAndGroupCompanies)
        RouterVC().pushViewController(viewController: vc)
    }
    
    func goToCommercialEmailMessages() {
        let vc = FullscreenTextController(text: TextConstants.commercialEmailMessages)
        RouterVC().pushViewController(viewController: vc)
    }
    
    func goToPrivacyPolicyDescriptionController() {
        let newViewController = PrivacyPolicyController()
        RouterVC().pushViewController(viewController: newViewController)
    }
    
}
