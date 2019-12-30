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
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew]
    }

    class func initializeAlbumsController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .createAlbum])
        viewController.scrollablePopUpView.addPermittedPopUpViewTypes(types: [.sync, .upload])
        viewController.scrollablePopUpView.isEnable = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .removeAlbum],
                                               style: .default, tintColor: nil)
        
        let presenter = AlbumsPresenter()
        
        if let moduleOutput = moduleOutput {
            presenter.sliderModuleOutput = moduleOutput
        }
        
        let router = AlbumsRouter()
        router.presenter = presenter
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 140))
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: albumsSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: router,
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.completelyMoveToTrash]),
                               topBarConfig: gridListTopBarConfig)
        
        interactor.originalFilters = [.fileType(.photoAlbum)]
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }
    
    class func initializeSelectAlbumsController(with nibName: String, photos: [BaseDataSourceItem]) -> AlbumSelectionViewController {
        let viewController = AlbumSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        //let bottomBarConfig = EditingBarConfig(elementsConfig: [],
        //                                       style: .default, tintColor: nil)
        
        let presenter = AlbumSelectionPresenter()
        
        
        let interactor = AlbumsInteractor(remoteItems: AlbumService(requestSize: 140))
        interactor.photos = photos
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: nil, router: AlbumsRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        
        interactor.originalFilters = [.fileType(.photoAlbum)]
        viewController.mainTitle = TextConstants.albumsTitle
        
        return viewController
    }

}
