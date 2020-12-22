//
//  PeriodicContactSyncConfigurator.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PeriodicContactSyncConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        
        if let viewController = viewInput as? PeriodicContactSyncViewController {
            configure(viewController: viewController)
        }
    }
    
    private func configure(viewController: PeriodicContactSyncViewController) {
        
        let router = PeriodicContactSyncRouter()
        
        let presenter = PeriodicContactSyncPresenter()
        presenter.view = viewController
        presenter.router = router
        
        let interactor = PeriodicContactSyncInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
