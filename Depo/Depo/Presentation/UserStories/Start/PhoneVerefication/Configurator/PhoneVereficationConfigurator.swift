//
//  PhoneVereficationPhoneVereficationConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationModuleConfigurator {

    func configureModuleForViewInput(viewInput: UIViewController, withResponse response: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {

        if let viewController = viewInput as? PhoneVerificationViewController {
            configure(viewController: viewController, withResponse: response, userInfo: userInfo)
        }
    }

    private func configure(viewController: PhoneVerificationViewController, withResponse response: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {

        let router = PhoneVereficationRouter()

        let presenter = PhoneVereficationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PhoneVereficationInteractor()
        interactor.saveSignUpResponse(withResponse: response, andUserInfo: userInfo)
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
