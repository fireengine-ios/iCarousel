//
//  ActivityTimelineActivityTimelineConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActivityTimelineModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? ActivityTimelineViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: ActivityTimelineViewController) {

        let router = ActivityTimelineRouter()

        let presenter = ActivityTimelinePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ActivityTimelineInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
