//
//  PhoneVerificationModuleConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PhoneVerificationModuleConfigurator {
    func configure(viewController: PhoneVerificationViewController,
                   withResponse response: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {

        let router = PhoneVerificationRouter()

        let presenter = PhoneVerificationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PhoneVerificationInteractor()
        interactor.saveSignUpResponse(withResponse: response, andUserInfo: userInfo)
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
