//
//  LoginSettingsModuleConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LoginSettingsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, isTurkcell: Bool) {
        if let viewController = viewInput as? LoginSettingsViewController {
            configure(viewController: viewController, isTurkcell: isTurkcell)
        }
    }

    private func configure(viewController: LoginSettingsViewController, isTurkcell: Bool) {

        let router = LoginSettingsRouter()

        let presenter = LoginSettingsPresenter(isTurkcell: isTurkcell)
        presenter.view = viewController
        presenter.router = router

        let interactor = LoginSettingsInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
