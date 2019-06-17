//
//  TermsAndPolicyConfigurator.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TermsAndPolicyConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? TermsAndPolicyViewController {
            configure(viewController: viewController)
        }
    }
    
    private func configure(viewController: TermsAndPolicyViewController) {
        
        let router = TermsAndPolicyRouter()
        let presenter = TermsAndPolicyPresenter()
        presenter.view = viewController
        presenter.router = router
    
        let interactor = TermsAndPolicyInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
