//
//  PhoneVereficationPhoneVereficationConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? PhoneVereficationViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: PhoneVereficationViewController) {

        let router = PhoneVereficationRouter()

        let presenter = PhoneVereficationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PhoneVereficationInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
