//
//  SelectNameSelectNameConfigurator.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameModuleConfigurator {
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, viewType: SelectNameScreenType, rootFolderID: String?, isFavorites: Bool = false, moduleOutput: SelectNameModuleOutput?) {
        
        if let viewController = viewInput as? SelectNameViewController {
            configure(viewController: viewController,
                      moduleType: viewType,
                      rootFolderID: rootFolderID,
                      isFavorites: isFavorites, 
                      moduleOutput: moduleOutput)
        }
    }
    
    private func configure(viewController: SelectNameViewController, moduleType: SelectNameScreenType, rootFolderID: String?, isFavorites: Bool = false, moduleOutput: SelectNameModuleOutput?) {        
        let router = SelectNameRouter()
        
        let presenter = SelectNamePresenter()
        presenter.view = viewController
        presenter.router = router
        
        presenter.selectNameModuleOutput = moduleOutput
        
        let interactor = SelectNameInteractor()
        interactor.output = presenter
        interactor.rootFolderID = rootFolderID
        interactor.isFavorite = isFavorites
        interactor.moduleType = moduleType
        
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
