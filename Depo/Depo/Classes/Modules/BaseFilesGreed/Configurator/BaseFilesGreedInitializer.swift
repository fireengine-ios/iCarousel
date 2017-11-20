//
//  BaseFilesGreedInitializer.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var baseFilesGreedViewController: BaseFilesGreedViewController!
    
    static var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ,.AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    class func initializePhotoVideosViewController(with nibName:String) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete, .sync, .download, .addToAlbum],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: true,
            showGridListButton: false
        )

        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                  selectionModeTypes: [.createStory])

        configurator.configure(viewController: viewController, remoteServices: PhotoAndVideoService(requestSize: 100),
                               fileFilters: [.fileType(.image)],
                               bottomBarConfig: bottomBarConfig, visibleSlider: true,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: alertSheetConfig)
        viewController.mainTitle = ""
        return viewController
    }
    
    class func initializeMusicViewController(with nibName:String) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: MusicService(requestSize: 100),
                               fileFilters: [.fileType(.audio)],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        return viewController
    }
    
    class func initializeDocumentsViewController(with nibName:String) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: DocumentService(requestSize: 100),
                               fileFilters: [.fileType(.allDocs)],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        return viewController
    }
    
    class func initializeAllFilesViewController(with nibName:String) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: AllFilesService(requestSize: 100),
                               fileFilters: [.localStatus(.nonLocal), .parentless ],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = TextConstants.homeButtonAllFiles
        return viewController
    }
    
    class func initializeFavoritesViewController(with nibName:String) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.isFavorites = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete, .sync, .download],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: FavouritesService(requestSize: 100),
                               fileFilters: [.favoriteStatus(.favorites)],
                                bottomBarConfig: bottomBarConfig,
                                topBarConfig: gridListTopBarConfig,
                                alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                      selectionModeTypes: []))
        viewController.mainTitle = TextConstants.homeButtonFavorites
        return viewController
    }
    
    class func initializeFilesFromFolderViewController(with nibName:String, folder: Item) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete, .sync, .download],
                                               style: .default, tintColor: nil)

        let presenter: BaseFilesGreedPresenter = DocumentsGreedPresenter()
        let interactor = BaseFilesGreedInteractor(remoteItems: FilesFromFolderService(requestSize: 999, rootFolder: folder.uuid))
        interactor.folder = folder
        
        configurator.configure(viewController: viewController, fileFilters: [.rootFolder(folder.uuid)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        viewController.mainTitle = folder.name
        return viewController
    }

}
