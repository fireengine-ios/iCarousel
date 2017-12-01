//
//  PasscodeSettingsPasscodeSettingsConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeSettingsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, inNeedOfMail: Bool) {
        if let viewController = viewInput as? PasscodeSettingsViewController {
            configure(viewController: viewController, inNeedOfMail: inNeedOfMail)
        }
    }

    private func configure(viewController: PasscodeSettingsViewController, inNeedOfMail: Bool) {

        let router = PasscodeSettingsRouter()

        let presenter = PasscodeSettingsPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PasscodeSettingsInteractor()
        interactor.output = presenter
        interactor.isEmptyMail = inNeedOfMail
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
