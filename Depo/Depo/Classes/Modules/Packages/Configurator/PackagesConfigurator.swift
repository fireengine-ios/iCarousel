//
//  PackagesPackagesConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? PackagesViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: PackagesViewController) {

        let router = PackagesRouter()

        let presenter = PackagesPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PackagesInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
