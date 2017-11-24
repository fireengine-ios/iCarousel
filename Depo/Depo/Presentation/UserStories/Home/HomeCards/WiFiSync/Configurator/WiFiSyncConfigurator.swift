//
//  WiFiSyncWiFiSyncConfigurator.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WiFiSyncModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? WiFiSyncViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: WiFiSyncViewController) {

        let router = WiFiSyncRouter()

        let presenter = WiFiSyncPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = WiFiSyncInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
