//
//  ResetPasswordOTPConfigurator.swift
//  Depo
//
//  Created by Hady on 9/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class ResetPasswordOTPModuleConfigurator {
    func configure(viewController: PhoneVerificationViewController,
                   resetPasswordService: ResetPasswordService, phoneNumber: String) {
        let router = PhoneVerificationRouter()

        let presenter = ResetPasswordOTPPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ResetPasswordOTPInteractor(resetPasswordService: resetPasswordService,
                                                    phoneNumber: phoneNumber)
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
