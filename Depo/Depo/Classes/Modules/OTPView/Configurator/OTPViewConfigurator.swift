//
//  OTPViewOTPViewConfigurator.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class OTPViewModuleConfigurator {

    func configure(viewController: OTPViewController, responce: SignUpSuccessResponse, userInfo: AccountInfoResponse) {

        let router = PhoneVereficationRouter()

        let presenter = OTPViewPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = OTPViewInteractor()
        interactor.output = presenter
        interactor.responce = responce
        interactor.userInfo = userInfo

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
