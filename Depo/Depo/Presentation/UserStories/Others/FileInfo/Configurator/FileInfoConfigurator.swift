//
//  FileInfoFileInfoConfigurator.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FileInfoModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? FileInfoViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: FileInfoViewController) {

        let router = FileInfoRouter()

        let presenter = FileInfoPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = FileInfoInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.interactor = interactor
    }

}
