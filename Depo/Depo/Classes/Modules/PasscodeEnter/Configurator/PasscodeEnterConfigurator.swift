//
//  PasscodeEnterPasscodeEnterConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeEnterModuleConfigurator {

    weak var delegate: PasscodeEnterDelegate?
    let type: PasscodeInputViewType
    
    init(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType = .validate) {
        self.delegate = delegate
        self.type = type
    }
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? PasscodeEnterViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: PasscodeEnterViewController) {

        let router = PasscodeEnterRouter()

        let presenter = PasscodeEnterPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.delegate = delegate
        presenter.type = type

        let interactor = PasscodeEnterInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
