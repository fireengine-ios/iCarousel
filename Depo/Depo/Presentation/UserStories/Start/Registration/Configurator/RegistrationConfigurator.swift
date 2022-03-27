//
//  RegistrationRegistrationConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, user: GoogleUser? = nil) {

        if let viewController = viewInput as? RegistrationViewController {
            configure(viewController: viewController, user: user)
        }
    }

    private func configure(viewController: RegistrationViewController, user: GoogleUser?) {

        let router = RegistrationRouter()

        let presenter = RegistrationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = RegistrationInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.googleUser = user
    }

}
