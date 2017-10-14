//
//  FeedbackViewFeedbackViewConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FeedbackViewModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? FeedbackViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: FeedbackViewController) {

        let router = FeedbackViewRouter()

        let presenter = FeedbackViewPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = FeedbackViewInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
