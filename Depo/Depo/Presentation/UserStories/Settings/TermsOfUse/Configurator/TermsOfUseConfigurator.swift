//
//  TermsOfUseConfigurator.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class TermsOfUseModuleConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? TermsOfUseViewController {
            configure(viewController: viewController)
        }
    }
    
    private func configure(viewController: TermsOfUseViewController) {
        
        let router = TermsOfUseRouter()
        
        let presenter = TermsOfUsePresenter()
        presenter.view = viewController
        presenter.router = router
        
        let interactor = TermsOfUseInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
