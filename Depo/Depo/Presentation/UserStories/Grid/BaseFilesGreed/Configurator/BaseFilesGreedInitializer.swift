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
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonCreateAStory, .floatingButtonCreateAlbum])
        viewController.scrolliblePopUpView.addNotPermittedPopUpViewTypes(types: [.waitingForWiFi, .autoUploadIsOff, .freeAppSpace, .freeAppSpaceWarning])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .delete, .sync, .download, .addToAlbum],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: [.AlphaBetricAZ, .AlphaBetricZA, .metaDataTimeNewOld, .metaDataTimeOldNew, .Largest, .Smallest],
            defaultSortType: .metaDataTimeNewOld,
            availableFilter: true,
            showGridListButton: false
        )

        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
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
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto])
        viewController.scrolliblePopUpView.isEnable = false
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
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto])
        viewController.scrolliblePopUpView.isEnable = false
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
    
    class func initializeAllFilesViewController(with nibName: String, moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonCreateAStory, .floatingButtonNewFolder])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: viewType,
            availableSortTypes: baseSortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController,
                               moduleOutput: moduleOutput,
                               remoteServices: AllFilesService(requestSize: 100),
                               fileFilters: [.localStatus(.nonLocal), .parentless ],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.rename]),
                               alertSheetExcludeTypes: [.print])
        viewController.mainTitle = TextConstants.homeButtonAllFiles
        return viewController
    }
    
    class func initializeFavoritesViewController(with nibName: String, moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonCreateAStory])
        viewController.isFavorites = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: viewType,
            availableSortTypes: baseSortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController,
                               moduleOutput: moduleOutput,
                               remoteServices: FavouritesService(requestSize: 100),
                               fileFilters: [.favoriteStatus(.favorites), .localStatus(.nonLocal)],
                                bottomBarConfig: bottomBarConfig,
                                topBarConfig: gridListTopBarConfig,
                                alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                      selectionModeTypes: [.rename]),
                                alertSheetExcludeTypes: [.print])
        viewController.mainTitle = TextConstants.homeButtonFavorites
        return viewController
    }
    
    class func initializeFilesFromFolderViewController(with nibName:String, folder: Item, type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?, alertSheetExcludeTypes: [ElementTypes]? = nil) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move,.delete],
                                               style: .default, tintColor: nil)

        let presenter: BaseFilesGreedPresenter = DocumentsGreedPresenter()
        if let alertSheetExcludeTypes = alertSheetExcludeTypes {
            presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        }
        let interactor = BaseFilesGreedInteractor(remoteItems: FilesFromFolderService(requestSize: 999, rootFolder: folder.uuid))
        interactor.folder = folder
        viewController.parentUUID = folder.uuid
        
        if let output = moduleOutput {
            presenter.moduleOutput = output
        }
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: baseSortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        
        configurator.configure(viewController: viewController, fileFilters: [.rootFolder(folder.uuid)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                               selectionModeTypes: [.rename]),
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = folder.name ?? ""

        return viewController
    }

}
