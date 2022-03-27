//
//  LoginLoginConfigurator.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LoginModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, user: GoogleUser? = nil) {

        if let viewController = viewInput as? LoginViewController {
            configure(viewController: viewController, user: user)
        }
    }

    private func configure(viewController: LoginViewController, user: GoogleUser?) {

        let router = LoginRouter()

        let presenter = LoginPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = LoginInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.googleUser = user
    }

}
