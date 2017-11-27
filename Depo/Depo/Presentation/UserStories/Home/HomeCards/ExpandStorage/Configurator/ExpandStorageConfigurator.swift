//
//  ExpandStorageExpandStorageConfigurator.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ExpandStorageModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? ExpandStorageViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: ExpandStorageViewController) {

        let router = ExpandStorageRouter()

        let presenter = ExpandStoragePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ExpandStorageInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
