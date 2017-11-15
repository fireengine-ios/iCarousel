//
//  FreeAppSpaceFreeAppSpaceConfigurator.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpaceModuleConfigurator {

    func configure(viewController: BaseFilesGreedViewController, remoteServices: RemoteItemsService) {
        
        let router = FreeAppSpaceRouter()
        
        let presenter = FreeUpSpacePresenter()
        
        presenter.view = viewController
        presenter.router = router
        
        let interactor = FreeUpSpaceInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
