//
//  AutoSyncAutoSyncConfigurator.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? AutoSyncViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: AutoSyncViewController) {

        let router = AutoSyncRouter()

        let presenter = AutoSyncPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = AutoSyncInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
