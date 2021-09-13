//
//  PackagesPackagesConfigurator.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesModuleConfigurator {
    func configure(viewController: PackagesViewController,
                   quotaInfo: QuotaInfoResponse? = nil,
                   affiliate: String? = nil) {
        let router = PackagesRouter()

        let presenter = PackagesPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.tuneUpQuota(quotaInfo: quotaInfo)

        let interactor = PackagesInteractor()
        interactor.output = presenter
        interactor.affiliate = affiliate

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
