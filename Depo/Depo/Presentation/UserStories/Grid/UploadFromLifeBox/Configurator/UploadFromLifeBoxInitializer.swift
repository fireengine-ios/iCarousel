//
//  UploadFromLifeBoxUploadFromLifeBoxInitializer.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxModuleInitializer: NSObject {

    class func initializePhotoVideosViewController(with nibName:String, albumUUID: String) -> UIViewController {
        let viewController = UploadFromLifeBoxViewController(nibName: nibName, bundle: nil)
        //viewController.needShowTabBar = true
        //viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [],
                                               style: .default, tintColor: nil)
        
        let presenter: BaseFilesGreedPresenter = UploadFromLifeBoxPhotosPresenter()
        let interactor = UploadFromLifeBoxInteractor(remoteItems: PhotoAndVideoService(requestSize: 100))
        interactor.rootFolderUUID = albumUUID
        
        configurator.configure(viewController: viewController, fileFilters: [.localStatus(.nonLocal), .fileType(.image), .fileType(.video)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        //viewController.mainTitle = folder.name
        return viewController
    }
    
    class func initializeFilesForFolderViewController(with nibName:String, destinationFolderUUID: String, outputFolderUUID: String = "") -> UIViewController {
        let viewController = UploadFromLifeBoxViewController(nibName: nibName, bundle: nil)
        viewController.parentUUID = destinationFolderUUID
        //viewController.needShowTabBar = true
        //viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonNewFolder, .floatingButtonUploadFromLifebox])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [],
                                               style: .default, tintColor: nil)
        
        let presenter: BaseFilesGreedPresenter = UploadFromLifeBoxAllFilesPresenter()
        var fileService: RemoteItemsService
        
        if !outputFolderUUID.isEmpty {
            fileService = FilesFromFolderService(requestSize: 100, rootFolder: outputFolderUUID)
        }else{
            fileService = AllFilesService(requestSize: 100)
        }
        
        let interactor = UploadFromLifeBoxInteractor(remoteItems: fileService)
        
        interactor.rootFolderUUID = destinationFolderUUID
        
        configurator.configure(viewController: viewController, fileFilters: [.localStatus(.nonLocal), .fileType(.image), .fileType(.video)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)
        //viewController.mainTitle = folder.name
        
        let router: BaseFilesGreedRouter = UploadFromLifeBoxRouter()
        presenter.router = router
        
        return viewController
    }
    
}
