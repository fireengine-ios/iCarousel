//
//  UsageInfoConfigurator.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class UsageInfoConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {
        if let viewController = viewInput as? UsageInfoViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: UsageInfoViewController) {
        
        let router = UsageInfoRouter()

        let presenter = UsageInfoPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = UsageInfoInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
