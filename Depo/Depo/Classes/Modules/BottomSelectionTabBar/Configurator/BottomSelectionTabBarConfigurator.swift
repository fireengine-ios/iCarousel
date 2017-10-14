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
                                                       config: EditingBarConfig) {

        if let viewController = viewInput as? BottomSelectionTabBarViewController {
            configure(viewController: viewController, settablePresenter: presenter, config: config)
        }
    }

    private func configure(viewController: BottomSelectionTabBarViewController,
                           settablePresenter: BottomSelectionTabBarPresenter?,
                           config: EditingBarConfig) {

        let router = BottomSelectionTabBarRouter()
        
        var presenter: BottomSelectionTabBarPresenter
        if let settablePresenter = settablePresenter {
            presenter = settablePresenter
        } else {
            presenter = BottomSelectionTabBarPresenter()
        }
        
        presenter.view = viewController
        presenter.router = router

        let interactor = BottomSelectionTabBarInteractor()
        interactor.dataStorage.currentBarConfig = config
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
