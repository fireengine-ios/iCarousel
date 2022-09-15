//
//  MyStorageModuleConfigurator.swift
//  Depo
//
//  Created by Raman Horhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class MyStorageModuleConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, usage: UsageResponse?, affiliate: String? = nil, refererToken: String? = nil) {
        if let viewController = viewInput as? MyStorageViewController {
            configure(with: viewController, usage: usage, affiliate: affiliate, refererToken: refererToken)
        }
    }

    private func configure(with view: MyStorageViewController, usage: UsageResponse?, affiliate: String? = nil, refererToken: String? = nil) {
        let router = MyStorageRouter()
        
        let presenter = MyStoragePresenter(title: TextConstants.myPackages)
        presenter.view = view
        presenter.router = router
        if let storageUsage = usage {
            presenter.usage = storageUsage
        }
        
        let interactor = MyStorageInteractor()
        interactor.output = presenter
        interactor.affiliate = affiliate
        interactor.refererToken = refererToken
        
        presenter.interactor = interactor
        view.output = presenter
    }
}
