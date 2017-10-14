//
//  CreateStoryNameCreateStoryNameConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryNameModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? CreateStoryNameViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: CreateStoryNameViewController) {

        let router = CreateStoryNameRouter()

        let presenter = CreateStoryNamePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CreateStoryNameInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
