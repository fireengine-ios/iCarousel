//
//  AlbumDetailAlbumDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumDetailModuleInitializer: NSObject {
    
    static var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    //Connect with object on storyboard
    class func initializeAlbumDetailController(with nibName: String, album: AlbumItem, type: MoreActionsConfig.ViewType, moduleOutput: BaseFilesGreedModuleOutput?) -> AlbumDetailViewController {
        let viewController = AlbumDetailViewController(nibName: nibName, bundle: nil)
        viewController.album = album
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .uploadFromLifebox])
        viewController.scrollablePopUpView.addPermittedPopUpViewTypes(types: [.sync, .upload])
        viewController.scrollablePopUpView.isEnable = true
        let configurator = BaseFilesGreedModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .addToAlbum, .hide, .delete],
                                                      style: .default, tintColor: nil)
        
        
        let presenter = SubscribedAlbumDetailPresenter()
        presenter.moduleOutput = moduleOutput
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 140))
        interactor.album = album
        
        // FIXME: need to change folder property to uuid in base class
        let item = Item(imageData: Data()) /// some empty item to pass uuid
        item.uuid = album.uuid
        interactor.folder = item
        
        viewController.parentUUID = album.uuid
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: false
        )
        
        let selectionModeTypes: [ElementTypes]
        
        let langCode = Device.locale
        if langCode != "tr" {
            selectionModeTypes = [.createStory, .removeFromAlbum ]
        } else {
            selectionModeTypes = [.createStory, .print, .removeFromAlbum ]
        }
        
        configurator.configure(viewController: viewController, fileFilters: [.rootAlbum(album.uuid), .localStatus(.nonLocal)],
                               bottomBarConfig: bottomBarConfig, router: AlbumDetailRouter(),
                               presenter: presenter, interactor: interactor,

                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.shareAlbum, .download, .completelyMoveToTrash, .removeAlbum, .albumDetails, .hideAlbums, .select],
                                                                                     selectionModeTypes: selectionModeTypes),
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = album.name ?? ""
        
        return viewController
    }
    
    class func initializeHiddenAlbumDetailController(with nibName: String, album: AlbumItem, type: MoreActionsConfig.ViewType, moduleOutput: BaseFilesGreedModuleOutput?) -> AlbumDetailViewController {
        
        let viewController = AlbumDetailViewController(nibName: nibName, bundle: nil)
        viewController.album = album
        
        viewController.isHiddenAlbum = true
        
        viewController.needToShowTabBar = false
        
        viewController.scrollablePopUpView.addPermittedPopUpViewTypes(types: [.sync, .upload])
        viewController.scrollablePopUpView.isEnable = true
        
        let configurator = BaseFilesGreedModuleConfigurator()
        
        let allowedHideFunctions: [ElementTypes] = [.unhide, .delete]
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: allowedHideFunctions, style: .default, tintColor: nil)
        
        let presenter = SubscribedHiddenAlbumDetailPresenter()
        presenter.moduleOutput = moduleOutput
        
        let interactor = AlbumDetailInteractor(remoteItems: AlbumDetailService(requestSize: 140))
        interactor.album = album
        
        // FIXME: need to change folder property to uuid in base class
        let item = Item(imageData: Data()) /// some empty item to pass uuid
        item.uuid = album.uuid
        interactor.folder = item
        
        viewController.parentUUID = album.uuid
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: false
        )
        
        presenter.alertSheetExcludeTypes = [.addToFavorites]

        configurator.configure(viewController: viewController, fileFilters: [.rootAlbum(album.uuid), .localStatus(.nonLocal)],
                               bottomBarConfig: bottomBarConfig, router: HiddenAlbumDetailRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: allowedHideFunctions,
                                                                                     selectionModeTypes: allowedHideFunctions),
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = album.name ?? ""
        
        return viewController
        
    }
}
