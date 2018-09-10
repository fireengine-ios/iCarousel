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
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .uploadFromLifebox])
        viewController.scrolliblePopUpView.addPermittedPopUpViewTypes(types: [.sync, .upload])
        viewController.scrolliblePopUpView.isEnable = true
        let configurator = BaseFilesGreedModuleConfigurator()
        
        var bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .print, .addToAlbum, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        
        let langCode = Device.locale
        if langCode != "tr", langCode != "en" {
            bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .addToAlbum, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        }
        
        let presenter = AlbumDetailPresenter()
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
        
        configurator.configure(viewController: viewController, fileFilters: [.rootAlbum(album.uuid), .localStatus(.nonLocal)],
                               bottomBarConfig: bottomBarConfig, router: AlbumDetailRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.shareAlbum, .download, .completelyDeleteAlbums, .removeAlbum, .albumDetails, .select],
                                                                                     selectionModeTypes: [.createStory, .delete]),
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = album.name ?? ""
        
        return viewController
    }
    
}
