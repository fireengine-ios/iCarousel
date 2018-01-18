//
//  SyncContactsSyncContactsConfigurator.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SyncContactsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? SyncContactsViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: SyncContactsViewController) {
        let router = SyncContactsRouter()

        let presenter = SyncContactsPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = SyncContactsInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
