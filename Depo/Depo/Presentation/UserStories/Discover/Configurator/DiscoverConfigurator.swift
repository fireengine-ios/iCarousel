//
//  DiscoverConfigurator.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class DiscoverConfigurator {
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? DiscoverViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: DiscoverViewController) {
        let router = DiscoverRouter()

        let presenter = DiscoverPresenter()
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        
        let interactor = DiscoverInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
