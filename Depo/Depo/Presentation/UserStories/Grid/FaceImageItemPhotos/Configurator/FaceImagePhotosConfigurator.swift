//
//  FaceImagePhotosConfigurator.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosConfigurator {
    
    var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    func configure(viewController: FaceImagePhotosViewController, album: AlbumItem, item: Item, moduleOutput: FaceImageItemsModuleOutput?, isSearchItem: Bool) {
        let router = FaceImagePhotosRouter()
        router.view = viewController
        router.item = item
        
        let presenter = FaceImagePhotosPresenter(item: item, isSearchItem: isSearchItem)
    
        var selectionModeTypes: [ElementTypes] = [.createStory, .print, .removeFromFaceImageAlbum]
        
        let langCode = Device.locale
        if langCode != "tr" {
            selectionModeTypes = [.createStory, .removeFromFaceImageAlbum]
        }
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select, .changeCoverPhoto],
                                                                   selectionModeTypes: selectionModeTypes)
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        presenter.view = viewController
        presenter.router = router
        presenter.faceImageItemsModuleOutput = moduleOutput
        presenter.needShowEmptyMetaItems = true
        
        let remoteServices = FaceImageDetailService(albumUUID: album.uuid, requestSize: RequestSizeConstant.faceImageItemsRequestSize)
        
        let interactor = FaceImagePhotosInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        interactor.album = album
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .addToAlbum, .hide, .deleteFaceImage],
                                               style: .default, tintColor: nil)
        
        
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
        
        viewController.mainTitle = item.name ?? ""
        
        presenter.item = item
        presenter.coverPhoto = album.preview
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: false
        )
        
        presenter.topBarConfig = gridListTopBarConfig
        let gridListTopBar = GridListTopBar.initFromXib()
        viewController.underNavBarBar = gridListTopBar
        gridListTopBar.delegate = viewController
    }
}
