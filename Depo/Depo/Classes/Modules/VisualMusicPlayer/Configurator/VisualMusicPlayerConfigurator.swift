//
//  VisualMusicPlayerVisualMusicPlayerConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? VisualMusicPlayerViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: VisualMusicPlayerViewController) {

        let router = VisualMusicPlayerRouter()

        let presenter = VisualMusicPlayerPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = VisualMusicPlayerInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
