//
//  LocalAlbumConfigurator.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LocalAlbumConfigurator: BaseFilesGreedModuleConfigurator {
    
    func configure(viewController: BaseFilesGreedChildrenViewController) {
        let router = LocalAlbumRouter()
        let presenter = LocalAlbumPresenter()
        
        presenter.view = viewController
        presenter.router = router
        
        let interactor = LocalAlbumInteractor(remoteItems: AlbumService(requestSize: 140))
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
        router.view = viewController
        router.presenter = presenter
    }
    
}
