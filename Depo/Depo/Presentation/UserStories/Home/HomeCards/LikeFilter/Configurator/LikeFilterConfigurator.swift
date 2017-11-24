//
//  LikeFilterLikeFilterConfigurator.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LikeFilterModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? LikeFilterViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: LikeFilterViewController) {

        let router = LikeFilterRouter()

        let presenter = LikeFilterPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = LikeFilterInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
