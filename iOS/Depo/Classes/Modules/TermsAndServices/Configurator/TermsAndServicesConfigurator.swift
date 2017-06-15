//
//  TermsAndServicesTermsAndServicesConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? TermsAndServicesViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: TermsAndServicesViewController) {

        let router = TermsAndServicesRouter()

        let presenter = TermsAndServicesPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = TermsAndServicesInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
