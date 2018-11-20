//
//  PremiumConfigurator.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumModuleConfigurator {
    
    func configure(viewController: PremiumViewController, title: String) {
        let router = PremiumRouter()
        router.view = viewController
        
        let presenter = PremiumPresenter(title: title)
        presenter.view = viewController
        presenter.router = router
        
        let interactor = PremiumInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
