//
//  EmailVerificationConfigurator.swift
//  Depo
//
//  Created by Hady on 1/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class EmailVerificationModuleConfigurator {
    func configure(viewController: PhoneVerificationViewController,
                   withResponse response: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {

        let router = EmailVerificationRouter()

        let presenter = EmailVerificationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = EmailVerificationInteractor()
        interactor.saveSignUpResponse(withResponse: response, andUserInfo: userInfo)
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
