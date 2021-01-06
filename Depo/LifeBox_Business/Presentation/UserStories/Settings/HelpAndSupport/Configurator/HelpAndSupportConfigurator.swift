//
//  HelpAndSupportHelpAndSupportConfigurator.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HelpAndSupportModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? HelpAndSupportViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: HelpAndSupportViewController) {

        let router = HelpAndSupportRouter()

        let presenter = HelpAndSupportPresenter()
        presenter.router = router

        let interactor = HelpAndSupportInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
    }

}
