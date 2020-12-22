//
//  HomePageHomePageConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomePageModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? HomePageViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: HomePageViewController) {

        let router = HomePageRouter()

        let presenter = HomePagePresenter()
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        
        let interactor = HomePageInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
