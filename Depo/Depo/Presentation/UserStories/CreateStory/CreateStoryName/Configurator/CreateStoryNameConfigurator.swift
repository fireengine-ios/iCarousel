//
//  CreateStoryNameCreateStoryNameConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryNameModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, needSelectionItems: Bool) {

        if let viewController = viewInput as? CreateStoryNameViewController {
            configure(viewController: viewController, needSelectionItems: needSelectionItems)
        }
    }

    private func configure(viewController: CreateStoryNameViewController, needSelectionItems: Bool) {

        let router = CreateStoryNameRouter()

        let presenter = CreateStoryNamePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CreateStoryNameInteractor()
        interactor.output = presenter
        interactor.needSelectionItems = needSelectionItems

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
