//
//  FAQModuleConfigurator.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FAQModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? FAQViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: FAQViewController) {

        let router = FAQRouter()

        let presenter = FAQPresenter()
        presenter.router = router

        let interactor = FAQInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
    }

}
