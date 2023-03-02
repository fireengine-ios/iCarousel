//
//  CreateCollageConfigurator.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class CreateCollageConfigurator {
//    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
//        if let viewController = viewInput as? CreateCollageViewController {
//            configure(viewController: viewController)
//        }
//    }
//
//    private func configure(viewController: CreateCollageViewController) {
//        let router = CreateCollageRouter()
//
//        let presenter = CreateCollagePresenter()
//        presenter.view = viewController
//        presenter.router = router
//        router.presenter = presenter
//
//        let interactor = CreateCollageInteractor()
//        interactor.output = presenter
//
//        presenter.interactor = interactor
//        viewController.output = presenter
//    }
    func configure(viewController: CreateCollageViewController) {

        let router = CreateCollageRouter()

        let presenter = CreateCollagePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = CreateCollageInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
