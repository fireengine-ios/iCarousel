//
//  PasscodeSettingsPasscodeSettingsConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeSettingsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, isTurkcell: Bool, inNeedOfMail: Bool) {
        if let viewController = viewInput as? PasscodeSettingsViewController {
            configure(viewController: viewController, isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)
        }
    }

    private func configure(viewController: PasscodeSettingsViewController, isTurkcell: Bool, inNeedOfMail: Bool) {

        let router = PasscodeSettingsRouter()

        let presenter = PasscodeSettingsPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PasscodeSettingsInteractor()
        interactor.output = presenter
        interactor.isEmptyMail = inNeedOfMail
        interactor.isTurkcellUser = isTurkcell
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
