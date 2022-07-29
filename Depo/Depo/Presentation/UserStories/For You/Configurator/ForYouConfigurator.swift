//
//  ForYouConfigurator.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class ForYouConfigurator {
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? ForYouViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: ForYouViewController) {
        let router = ForYouRouter()

        let presenter = ForYouPresenter()
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        
        let interactor = ForYouInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
