//
//  TwoFactorChallengeInitializer.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TwoFactorChallengeInitializer {
    
    class func viewController(otpParams: TwoFAChallengeParametersResponse, challenge: TwoFAChallengeModel) -> UIViewController {
        let nibName = "PhoneVereficationScreen"
        let viewController = PhoneVerificationViewController(nibName: nibName, bundle: nil)
        let configurator = TwoFactorChallengeConfigurator()
        configurator.configure(viewController: viewController, otpParams: otpParams, challenge: challenge)
        
        return viewController
    }
    
}
