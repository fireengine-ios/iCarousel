//
//  AlbumsAlbumsInitializer.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumsModuleInitializer: NSObject {
    
    static var albumsSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ,.AlphaBetricZA, .TimeNewOld, .TimeOldNew]
    }

    class func initializeAlbumsController(with nibName:String) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonCreateAStory, .floatingButtonCreateAlbum])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.delete],
                                               style: .default, tintColor: nil)
        
        let presentor = AlbumsPresenter()
        
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 140))
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: albumsSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: AlbumsRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.albumDetails]),
                               topBarConfig: gridListTopBarConfig)
        
        
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }
    
    class func initializeSelectAlbumsController(with nibName:String, photos:[BaseDataSourceItem]) -> AlbumSelectionViewController {
        let viewController = AlbumSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        //let bottomBarConfig = EditingBarConfig(elementsConfig: [],
        //                                       style: .default, tintColor: nil)
        
        let presentor = AlbumSelectionPresenter()
        
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 140))
        interactor.photos = photos
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: nil, router: AlbumsRouter(),
                               presenter: presentor, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }

}
