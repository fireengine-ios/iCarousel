//
//  PublicShareConfigurator.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareConfigurator {
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, publicToken: String) {
        if let viewController = viewInput as? PublicShareViewController {
            configure(viewController: viewController, publicToken: publicToken)
        }
    }
        
    func configureModuleForInnerFolder<UIViewController>(viewInput: UIViewController, item: WrapData) {
        if let viewController = viewInput as? PublicShareViewController {
            configureInnerFolder(viewController: viewController, item: item)
        }
    }
    
    private func configure(viewController: PublicShareViewController, publicToken: String) {
        let router = PublicShareRouter()

        let presenter = PublicSharePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PublicShareInteractor()
        interactor.output = presenter
        interactor.publicToken = publicToken

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.isMainFolder = true
    }
    
    private func configureInnerFolder(viewController: PublicShareViewController, item: WrapData) {
        let router = PublicShareRouter()

        let presenter = PublicSharePresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = PublicShareInteractor()
        interactor.output = presenter
        interactor.isInnerFolder = true
        interactor.item = item
        
        if let tmpListingUrl = item.tempListingURL {
            let queryItems = URLComponents(string: tmpListingUrl)?.queryItems
            let publicToken = queryItems?.filter({$0.name == "publicToken"}).first
            interactor.publicToken = publicToken?.value
        }

        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.mainTitle = item.name
    }
}

