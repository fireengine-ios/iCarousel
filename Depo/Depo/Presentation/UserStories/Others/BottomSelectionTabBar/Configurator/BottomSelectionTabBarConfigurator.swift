//
//  BottomSelectionTabBarBottomSelectionTabBarConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionTabBarModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController,
                                                       presenter: BottomSelectionTabBarPresenter?,
                                                       interactor: BottomSelectionTabBarInteractor,
                                                       router: BottomSelectionTabBarRouter,
                                                       config: EditingBarConfig) {

        if let viewController = viewInput as? BottomSelectionTabBarViewController {
            configure(viewController: viewController, settablePresenter: presenter, interactor: interactor, router: router, config: config)
        } else if let viewController = viewInput as? BottomSelectionTabBarDrawerViewController {
            configure(viewController: viewController, settablePresenter: presenter, interactor: interactor, router: router, config: config)
        }
    }

    private func configure(viewController: BottomSelectionTabBarViewController,
                           settablePresenter: BottomSelectionTabBarPresenter?,
                           interactor: BottomSelectionTabBarInteractor,
                           router: BottomSelectionTabBarRouter,
                           config: EditingBarConfig) {
        
        var presenter: BottomSelectionTabBarPresenter
        if let settablePresenter = settablePresenter {
            presenter = settablePresenter
        } else {
            presenter = BottomSelectionTabBarPresenter()
        }
        
        presenter.view = viewController
        presenter.router = router

        interactor.dataStorage.currentBarConfig = config
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

    private func configure(viewController: BottomSelectionTabBarDrawerViewController,
                           settablePresenter: BottomSelectionTabBarPresenter?,
                           interactor: BottomSelectionTabBarInteractor,
                           router: BottomSelectionTabBarRouter,
                           config: EditingBarConfig) {

        var presenter: BottomSelectionTabBarPresenter
        if let settablePresenter = settablePresenter {
            presenter = settablePresenter
        } else {
            presenter = BottomSelectionTabBarPresenter()
        }

        presenter.view = viewController
        presenter.router = router

        interactor.dataStorage.currentBarConfig = config
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
