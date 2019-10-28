//
//  PremiumConfigurator.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumModuleConfigurator {
    
    func configure(viewController: PremiumViewController,
                   title: String,
                   headerTitle: String,
                   authority: AuthorityType? = nil,
                   module: FaceImageItemsModuleOutput?,
                   viewControllerForPresentOn: UIViewController? = nil) {
        let router = PremiumRouter(viewControllerForPresentOn: viewControllerForPresentOn)
        
        let presenter = PremiumPresenter(title: title, headerTitle: headerTitle, authority: authority, module: module)
        presenter.view = viewController
        presenter.router = router
        
        let interactor = PremiumInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
