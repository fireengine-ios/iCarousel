//
//  TwoFactorChallengeRouter.swift
//  Depo
//
//  Created by Raman Harhun on 8/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TwoFactorChallengeRouter: PhoneVerificationRouter {
    
    override func goAutoSync() {
        ///RouterVC's present make no effect
        let controller = router.synchronyseScreen
        controller.modalPresentationStyle = .fullScreen
        
        router.defaultTopController?.present(controller, animated: true, completion: nil)
    }
    
    func goToTermsAndServices() {
        let temsAndServices = router.termsAndServicesScreen(login: true, phoneNumber: nil)
        router.pushViewController(viewController: temsAndServices)
    }
}
