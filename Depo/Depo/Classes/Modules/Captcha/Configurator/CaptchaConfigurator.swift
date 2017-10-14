//
//  CaptchaCaptchaConfigurator.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CaptchaModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? CaptchaViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: CaptchaViewController) {

        let presenter = CaptchaPresenter()
        presenter.view = viewController
        presenter.captchaDelegate = nil

        let interactor = CaptchaInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
