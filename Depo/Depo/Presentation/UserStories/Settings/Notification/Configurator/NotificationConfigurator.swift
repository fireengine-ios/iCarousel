//
//  NotificationConfigurator.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

class NotificationConfigurator {
    func configure(viewController: NotificationViewController) {

        let router = NotificationRouter()

        let presenter = NotificationPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = NotificationInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
