//
//  SaveToMyLifeboxConfigurator.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class SaveToMyLifeboxConfigurator {
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, publicToken: String) {
        if let viewController = viewInput as? SaveToMyLifeboxViewController {
            configure(viewController: viewController, publicToken: publicToken)
        }
    }
        
    func configureModuleForInnerFolder<UIViewController>(viewInput: UIViewController, item: WrapData) {
        if let viewController = viewInput as? SaveToMyLifeboxViewController {
            configureInnerFolder(viewController: viewController, item: item)
        }
    }
    
    private func configure(viewController: SaveToMyLifeboxViewController, publicToken: String) {
        let router = SaveToMyLifeboxRouter()

        let presenter = SaveToMyLifeboxPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = SaveToMyLifeboxInteractor()
        interactor.output = presenter
        interactor.publicToken = publicToken

        presenter.interactor = interactor
        viewController.output = presenter
    }
    
    private func configureInnerFolder(viewController: SaveToMyLifeboxViewController, item: WrapData) {
        let router = SaveToMyLifeboxRouter()

        let presenter = SaveToMyLifeboxPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = SaveToMyLifeboxInteractor()
        interactor.output = presenter
        interactor.isInnerFolder = true
        interactor.item = item

        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.mainTitle = item.name
    }
}

