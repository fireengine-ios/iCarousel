//
//  FaceImagePhotosConfigurator.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosConfigurator {
    
    func configure(viewController: FaceImagePhotosViewController, albumUUID: String, item: Item) {
        let router = FaceImagePhotosRouter()
        
        let presenter = FaceImagePhotosPresenter()
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                   selectionModeTypes: [.createStory,.addToFavorites,.delete])
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        presenter.view = viewController
        presenter.router = router
        
        let remoteServices = FaceImageDetailService(albumUUID: albumUUID, requestSize: 40)
        
        let interactor = FaceImagePhotosInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .print, .addToAlbum, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
        
        viewController.mainTitle = item.name ?? ""
    }
}
