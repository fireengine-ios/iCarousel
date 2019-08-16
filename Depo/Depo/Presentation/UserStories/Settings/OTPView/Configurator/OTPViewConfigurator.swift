//
//  OTPViewOTPViewConfigurator.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class OTPViewModuleConfigurator {

    func configure(viewController: PhoneVerificationViewController, response: SignUpSuccessResponse, userInfo: AccountInfoResponse, phoneNumber: String) {

        let router = PhoneVerificationRouter()

        let presenter = OTPViewPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = OTPViewInteractor()
        interactor.output = presenter
        interactor.response = response
        interactor.userInfo = userInfo
        interactor.phoneNumberString = phoneNumber

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
