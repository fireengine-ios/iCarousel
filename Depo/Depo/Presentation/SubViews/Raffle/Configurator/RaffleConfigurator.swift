//
//  RaffleConfigurator.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RaffleConfigurator {
    func configure(viewController: RaffleViewController) {
        
        let router = RaffleRouter()
        
        let presenter = RafflePresenter()
        presenter.view = viewController
        presenter.router = router
        
        let interactor = RaffleInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
