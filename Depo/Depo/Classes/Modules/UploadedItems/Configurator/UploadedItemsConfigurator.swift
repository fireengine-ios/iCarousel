//
//  UploadedItemsUploadedItemsConfigurator.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadedItemsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? UploadedItemsViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: UploadedItemsViewController) {

        let router = UploadedItemsRouter()

        let presenter = UploadedItemsPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = UploadedItemsInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
