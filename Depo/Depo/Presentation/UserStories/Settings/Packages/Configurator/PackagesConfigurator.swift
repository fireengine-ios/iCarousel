//
//  PackagesPackagesConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, quotoInfo: QuotaInfoResponse? = nil) {
        if let viewController = viewInput as? PackagesViewController {
            configure(viewController: viewController, quotoInfo: quotoInfo)
        }
    }

    private func configure(viewController: PackagesViewController, quotoInfo: QuotaInfoResponse? = nil) {
        let router = PackagesRouter()

        let presenter = PackagesPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.tuneUpQuota(quotaInfo: quotoInfo)

        let interactor = PackagesInteractor()
        interactor.output = presenter
        interactor.getQuotaInfo()

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
