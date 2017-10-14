//
//  ForgotPasswordForgotPasswordConfigurator.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ForgotPasswordModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? ForgotPasswordViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: ForgotPasswordViewController) {

        let router = ForgotPasswordRouter()

        let presenter = ForgotPasswordPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ForgotPasswordInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
        
        //capcha
        
//        let capchaModuleInitializer = CaptchaModuleInitializer()
//        capchaModuleInitializer.setupModule()
//        viewController.captchaModuleView = capchaModuleInitializer.captchaViewController
    }

}
