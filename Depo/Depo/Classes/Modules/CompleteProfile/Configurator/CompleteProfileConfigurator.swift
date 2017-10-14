//
//  CompleteProfileCompleteProfileConfigurator.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CompleteProfileModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? CompleteProfileViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: CompleteProfileViewController) {

        let router = CompleteProfileRouter()

        let presenter = CompleteProfilePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CompleteProfileInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
