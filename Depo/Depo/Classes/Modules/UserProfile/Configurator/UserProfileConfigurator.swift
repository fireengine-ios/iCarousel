//
//  UserProfileUserProfileConfigurator.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserProfileModuleConfigurator {

    func configure(viewController: UserProfileViewController, userInfo: AccountInfoResponse) {

        let router = UserProfileRouter()

        let presenter = UserProfilePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = UserProfileInteractor()
        interactor.output = presenter
        interactor.userInfo = userInfo

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
