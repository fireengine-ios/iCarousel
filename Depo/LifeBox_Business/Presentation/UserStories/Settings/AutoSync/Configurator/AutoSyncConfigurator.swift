//
//  AutoSyncAutoSyncConfigurator.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, fromSettings: Bool = false) {

        if let viewController = viewInput as? AutoSyncViewController {
            configure(viewController: viewController, fromSettings: fromSettings)
        }
    }

    private func configure(viewController: AutoSyncViewController, fromSettings: Bool = false) {

        let router = AutoSyncRouter()

        let presenter = AutoSyncPresenter()
        presenter.view = viewController
        presenter.router = router
        
        presenter.fromSettings = fromSettings
        viewController.fromSettings = fromSettings

        let interactor = AutoSyncInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.needToShowTabBar = false
    }

}
