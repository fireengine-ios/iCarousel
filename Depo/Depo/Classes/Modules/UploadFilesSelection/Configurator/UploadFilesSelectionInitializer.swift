//
//  UploadFilesSelectionUploadFilesSelectionInitializer.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFilesSelectionModuleInitializer: NSObject {
    
    class func initializeViewController(with nibName:String, searchService: RemoteItemsService) -> UIViewController {
        let viewController = UploadFilesSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: UploadFilesSelectionPresenter(),
                               interactor: UploadFilesSelectionInteractor(remoteItems: searchService),
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        return viewController
    }
    
    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = UploadFilesSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let service = LocalPhotoAndVideoService()

        configurator.configure(viewController: viewController,
                               bottomBarConfig: nil,
                               router: BaseFilesGreedRouter(),
                               presenter: UploadFilesSelectionPresenter(),
                               interactor: UploadFilesSelectionInteractor(remoteItems: service),
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []))
        
        viewController.mainTitle = ""
        return viewController
    }

    class func initializeUploadPhotosViewController() -> UIViewController {
//
        let viewController = UploadFilesSelectionViewController(nibName: "BaseFilesGreedViewController", bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let service = LocalPhotoAndVideoService()
        
        configurator.configure(viewController: viewController,
                               fileFilters: [.localStatus(.local), .syncStatus(.notSynced)],//[.duplicates],//
                               bottomBarConfig: nil,
                               router: BaseFilesGreedRouter(),
                               presenter: UploadFilesSelectionPresenter(),
                               interactor: UploadFilesSelectionInteractor(remoteItems: service),
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
                                                                                     selectionModeTypes: []))
        
        viewController.mainTitle = ""
        return viewController
    }
    
}
