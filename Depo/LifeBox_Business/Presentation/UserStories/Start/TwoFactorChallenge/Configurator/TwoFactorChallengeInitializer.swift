//
//  TwoFactorChallengeInitializer.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TwoFactorChallengeInitializer {
    
    class func viewController(otpParams: TwoFAChallengeParametersResponse, challenge: TwoFAChallengeModel, rememberMe: Bool) -> UIViewController {
        let nibName = "PhoneVerificationScreen"
        let viewController = PhoneVerificationViewController(nibName: nibName, bundle: nil)
        let configurator = TwoFactorChallengeConfigurator()
        configurator.configure(viewController: viewController, otpParams: otpParams, challenge: challenge, rememberMe: rememberMe)
        
        return viewController
    }
    
}
