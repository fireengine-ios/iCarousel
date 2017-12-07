//
//  HomeHeaderHomeHeaderConfigurator.swift
//  Depo
//
//  Created by Oleg on 28/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomeHeaderModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? HomeHeaderViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: HomeHeaderViewController) {

        let router = HomeHeaderRouter()

        let presenter = HomeHeaderPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = HomeHeaderInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
