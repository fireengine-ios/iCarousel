//
//  ForgotPasswordForgotPasswordConfigurator.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ForgotPasswordModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, loginText: String) {

        if let viewController = viewInput as? ForgotPasswordViewController {
            configure(viewController: viewController, loginText: loginText)
        }
    }

    private func configure(viewController: ForgotPasswordViewController, loginText: String) {

        let router = ForgotPasswordRouter()

        let presenter = ForgotPasswordPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ForgotPasswordInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.loginEnterViewText = loginText
    }

}
