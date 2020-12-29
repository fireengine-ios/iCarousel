//
//  IntroduceIntroduceConfigurator.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class IntroduceModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? IntroduceViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: IntroduceViewController) {

        let router = IntroduceRouter()

        let presenter = IntroducePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = IntroduceInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
