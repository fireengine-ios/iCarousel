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
    
    func configure(viewController: FaceImagePhotosViewController, album: AlbumItem, item: Item, status: ItemStatus, moduleOutput: FaceImageItemsModuleOutput?, isSearchItem: Bool) {
        let router = FaceImagePhotosRouter()
        router.view = viewController
        router.item = item

        viewController.mainTitle = item.name ?? ""
        viewController.status = status
        
        let presenter = FaceImagePhotosPresenter(item: item, isSearchItem: isSearchItem)
        presenter.view = viewController
        presenter.router = router
        presenter.faceImageItemsModuleOutput = moduleOutput
        presenter.needShowEmptyMetaItems = true
        presenter.item = item
        presenter.coverPhoto = album.preview
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        let remoteServices = FaceImageDetailService(albumUUID: album.uuid,
                                                    requestSize: RequestSizeConstant.faceImageItemsRequestSize)
        let interactor = FaceImagePhotosInteractor(remoteItems: remoteServices)
        
        interactor.output = presenter
        interactor.album = album
        interactor.status = status
        
        let initialTypes = ElementTypes.faceImagePhotosElementsConfig(for: item, status: status, viewType: .actionSheet)
        let selectionModeTypes = ElementTypes.faceImagePhotosElementsConfig(for: item, status: status, viewType: .selectionMode)
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: initialTypes,
                                                                   selectionModeTypes: selectionModeTypes)
        
        interactor.alertSheetConfig = alertSheetConfig
        presenter.interactor = interactor
        viewController.output = presenter
        
        let elementsConfig = ElementTypes.faceImagePhotosElementsConfig(for: item, status: status, viewType: .bottomBar)
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig, style: .default, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let bottomBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig,
                                                        settablePresenter: BottomSelectionTabBarPresenter())
        
        viewController.editingTabBar = bottomBarVC
        interactor.bottomBarOriginalConfig = bottomBarConfig
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        
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
