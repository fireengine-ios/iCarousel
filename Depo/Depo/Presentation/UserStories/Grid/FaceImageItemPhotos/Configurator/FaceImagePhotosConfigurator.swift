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
        
        let presenter = FaceImagePhotosPresenter(item: item, isSearchItem: isSearchItem)

        var elementsConfig: [ElementTypes] = [.share, .download, .addToAlbum, .hide, .deleteFaceImage]
        var initialTypes: [ElementTypes] = [.select]
        if item.fileType.isFaceImageType {
            switch status {
            case .hidden:
                initialTypes.append(contentsOf: [.unhide, .completelyMoveToTrash])
                ///to remove 3 dots from selection mode if it is hidden album
                viewController.isHiddenAlbum = true
                elementsConfig = [.unhideAlbumItems, .deleteFaceImage]
            case .trashed:
                initialTypes.append(contentsOf: [.changeCoverPhoto, .hide, .completelyDeleteAlbums])
            default:
                initialTypes.append(contentsOf: [.changeCoverPhoto, .hide, .completelyMoveToTrash])
            }
        }
        
        let selectionModeTypes: [ElementTypes]
        
        let langCode = Device.locale
        if langCode != "tr" {
            selectionModeTypes = [.createStory, .removeFromFaceImageAlbum]
        } else {
            selectionModeTypes = [.createStory, .print, .removeFromFaceImageAlbum]
        }
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: initialTypes,
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
        interactor.status = status
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
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
