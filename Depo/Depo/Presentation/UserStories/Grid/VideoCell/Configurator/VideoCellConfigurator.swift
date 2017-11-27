//
//  VideoCellVideoCellConfigurator.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VideoCellModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? VideoCellViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: VideoCellViewController) {

        let router = VideoCellRouter()

        let presenter = VideoCellPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = VideoCellInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
