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
        
    func configureModuleForInnerFolder<UIViewController>(viewInput: UIViewController, item: WrapData, itemCount: Int) {
        if let viewController = viewInput as? PublicShareViewController {
            configureInnerFolder(viewController: viewController, item: item, itemCount: itemCount)
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
        viewController.isRootFolder = true
    }
    
    private func configureInnerFolder(viewController: PublicShareViewController, item: WrapData, itemCount: Int) {
        let router = PublicShareRouter()

        let presenter = PublicSharePresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.itemCount = itemCount

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
        viewController.isRootFolder = false
        
        viewController.mainTitle = item.name
    }
}

