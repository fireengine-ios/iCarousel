//
//  ConnectedDeviceConfigurator.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class ConnectedDeviceConfigurator {
    func configure(viewController: ConnectedDeviceViewController) {

        let router = ConnectedDeviceRouter()

        let presenter = ConnectedDevicePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ConnectedDeviceInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
