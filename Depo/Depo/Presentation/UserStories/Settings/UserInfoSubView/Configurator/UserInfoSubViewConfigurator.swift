//
//  UserInfoSubViewUserInfoSubViewConfigurator.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserInfoSubViewModuleConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? UserInfoSubViewViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: UserInfoSubViewViewController) {
        let router = UserInfoSubViewRouter()

        let authorityStorage: AuthorityStorage = factory.resolve()

        let presenter = UserInfoSubViewPresenter(isPremiumUser: authorityStorage.isPremium ?? false)
        presenter.view = viewController
        presenter.router = router

        let interactor = UserInfoSubViewInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
