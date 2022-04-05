//
//  MapSearchConfigurator.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapSearchConfigurator {
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? MapSearchViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: MapSearchViewController) {
        let router = MapSearchRouter()

        let presenter = MapSearchPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = MapSearchInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
