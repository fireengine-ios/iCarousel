//
//  DuplicatedContactsConfigurator.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactsModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?) {

        if let viewController = viewInput as? DuplicatedContactsViewController {
            configure(viewController: viewController, analyzeResponse: analyzeResponse, moduleOutput: moduleOutput)
        }
    }

    private func configure(viewController: DuplicatedContactsViewController, analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?) {
        viewController.analyzeResponse = analyzeResponse
        
        let router = DuplicatedContactsRouter()

        let presenter = DuplicatedContactsPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.moduleOutput = moduleOutput
        
        let interactor = DuplicatedContactsInteractor()
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
