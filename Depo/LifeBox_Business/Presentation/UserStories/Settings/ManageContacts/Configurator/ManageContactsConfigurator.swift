//
//  ManageContactsConfigurator.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ManageContactsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, moduleOutput: ManageContactsModuleOutput?) {

        if let viewController = viewInput as? ManageContactsViewController {
            configure(viewController: viewController, moduleOutput: moduleOutput)
        }
    }

    private func configure(viewController: ManageContactsViewController, moduleOutput: ManageContactsModuleOutput?) {

        let router = ManageContactsRouter()

        let presenter = ManageContactsPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.moduleOutput = moduleOutput
        
        let interactor = ManageContactsInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
