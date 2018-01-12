//
//  TurkcellSecurityTurkcellSecurityConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TurkcellSecurityModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? TurkcellSecurityViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: TurkcellSecurityViewController) {

        let router = TurkcellSecurityRouter()

        let presenter = TurkcellSecurityPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = TurkcellSecurityInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
