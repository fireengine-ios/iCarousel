//
//  DrawCampaignConfigurator.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DrawCampaignConfigurator {
    func configure(viewController: DrawCampaignViewController) {

        let router = DrawCampaignRouter()

        let presenter = DrawCampaignPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = DrawCampaignInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
