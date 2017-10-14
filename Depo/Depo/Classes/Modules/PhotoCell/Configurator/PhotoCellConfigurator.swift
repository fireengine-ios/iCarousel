//
//  PhotoCellPhotoCellConfigurator.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoCellModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? PhotoCellViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: PhotoCellViewController) {

        let router = PhotoCellRouter()

        let presenter = PhotoCellPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PhotoCellInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.interactor = interactor
    }

}
