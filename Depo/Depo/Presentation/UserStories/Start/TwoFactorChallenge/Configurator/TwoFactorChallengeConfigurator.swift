//
//  TwoFactorChallengeConfigurator.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TwoFactorChallengeConfigurator {
    
    func configure(viewController: PhoneVerificationViewController,
                   otpParams: TwoFAChallengeParametersResponse,
                   challenge: TwoFAChallengeModel) {
        
        let router = TwoFactorChallengeRouter()
        let presenter = TwoFactorChallengePresenter()
        
        presenter.view = viewController
        presenter.router = router
        
        let interactor = TwoFactorChallengeInteractor(otpParams: otpParams, challenge: challenge)
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
