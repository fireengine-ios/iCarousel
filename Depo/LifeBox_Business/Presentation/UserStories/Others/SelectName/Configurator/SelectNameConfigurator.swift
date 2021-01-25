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
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, viewType: SelectNameScreenType, parameters: CreateFolderSharedWithMeParameters, moduleOutput: SelectNameModuleOutput?) {
        
        if let viewController = viewInput as? SelectNameViewController {
            configure(viewController: viewController,
                      moduleType: viewType,
                      rootFolderID: parameters.rootFolderUuid,
                      isPrivateSharing: true,
                      projectId: parameters.accountUuid,
                      moduleOutput: moduleOutput)
        }
    }
    
    private func configure(viewController: SelectNameViewController, moduleType: SelectNameScreenType, rootFolderID: String?, isFavorites: Bool = false, isPrivateSharing: Bool = false, projectId: String? = nil, moduleOutput: SelectNameModuleOutput?) {
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
        interactor.isPrivateShare = isPrivateSharing
        interactor.accountUuid = projectId
        
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
