//
//  UploadFromLifeBoxUploadFromLifeBoxInitializer.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxModuleInitializer: NSObject {

    class func initializePhotoVideosViewController(with nibName: String, albumUUID: String, sortedRule: SortedRules = .timeUp) -> UIViewController {
        let viewController = UploadFromLifeBoxViewController(nibName: nibName, bundle: nil)
        //viewController.needShowTabBar = true
        //viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [],
                                               style: .default, tintColor: nil)
        
        let presenter: BaseFilesGreedPresenter = UploadFromLifeBoxPhotosPresenter()
        presenter.sortedRule = sortedRule
        let interactor = UploadFromLifeBoxInteractor(remoteItems: PhotoAndVideoService(requestSize: 100))
        interactor.rootFolderUUID = albumUUID
        
        configurator.configure(viewController: viewController, fileFilters: [.localStatus(.nonLocal), .fileType(.imageAndVideo)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        //viewController.mainTitle = folder.name
        return viewController
    }
    
    class func initializeFilesForFolderViewController(with nibName: String, destinationFolderUUID: String, outputFolderUUID: String = "", sortRule: SortedRules, type: MoreActionsConfig.ViewType) -> UIViewController {
        let viewController = UploadFromLifeBoxViewController(nibName: nibName, bundle: nil)
        viewController.parentUUID = destinationFolderUUID
        //viewController.needShowTabBar = true
        //viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [],
                                               style: .default, tintColor: nil)
        
        let presenter: BaseFilesGreedPresenter = UploadFromLifeBoxAllFilesPresenter()
        presenter.sortedRule = sortRule
        presenter.type = type
        var fileService: RemoteItemsService
        
        if !outputFolderUUID.isEmpty {
            fileService = FilesFromFolderService(requestSize: 100, rootFolder: outputFolderUUID, status: .active)
        } else {
            fileService = AllFilesService(requestSize: 100)
        }
        
        let interactor = UploadFromLifeBoxInteractor(remoteItems: fileService)
        
        interactor.rootFolderUUID = destinationFolderUUID
        
        configurator.configure(viewController: viewController, fileFilters: [.localStatus(.nonLocal), .fileType(.imageAndVideo)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        //viewController.mainTitle = folder.name
        
        let router: BaseFilesGreedRouter = UploadFromLifeBoxRouter()
        presenter.router = router
        router.presenter = presenter
        
        return viewController
    }
    
    class func initializeUploadFromLifeBoxFavoritesController(destinationFolderUUID: String, outputFolderUUID: String = "", sortRule: SortedRules, isPhotoVideoOnly: Bool) -> UIViewController {
        let viewController = UploadFromLifeBoxViewController(nibName: "BaseFilesGreedViewController", bundle: nil)
        viewController.parentUUID = destinationFolderUUID
        //viewController.needShowTabBar = true
        //viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [],
                                               style: .default, tintColor: nil)
        
        let presenter: BaseFilesGreedPresenter
        let fileService: RemoteItemsService
        
        if isPhotoVideoOnly {
            fileService = PhotoAndVideoService(requestSize: 100)
            presenter = UploadFromLifeBoxPhotosPresenter()
        } else if !outputFolderUUID.isEmpty {
            fileService = FilesFromFolderService(requestSize: 100, rootFolder: outputFolderUUID, status: .active)
            presenter = UploadFromLifeBoxAllFilesPresenter()
        } else {
            fileService = AllFilesService(requestSize: 100)
            presenter = UploadFromLifeBoxAllFilesPresenter()
        }
        
        presenter.sortedRule = sortRule
        
        let interactor = UploadFromLifeBoxFavoritesInteractor(remoteItems: fileService)

        interactor.rootFolderUUID = destinationFolderUUID
        
        configurator.configure(viewController: viewController, fileFilters: [.localStatus(.nonLocal), .fileType(.imageAndVideo)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        //viewController.mainTitle = folder.name
        
        let router: BaseFilesGreedRouter = UploadFromLifeBoxRouterFavorites()
        presenter.router = router
        router.presenter = presenter
        
        return viewController
    }
}
