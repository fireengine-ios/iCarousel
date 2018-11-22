//
//  LeavePremiumConfigurator.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumModuleConfigurator {
    
    func configure(viewController: LeavePremiumViewController, title: String, activeSubscriptions: [SubscriptionPlanBaseResponse]) {
        let router = LeavePremiumRouter()
        router.view = viewController
        
        let presenter = LeavePremiumPresenter(title: title, activeSubscriptions: activeSubscriptions)
        presenter.view = viewController
        presenter.router = router
        
        let interactor = LeavePremiumInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
