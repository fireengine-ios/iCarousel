//
//  FreeUpSpaceFreeUpSpaceInitializer.swift
//  Depo
//
//  Created by Oleg on 04/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeUpSpaceModuleInitializer: NSObject {
    
    class func initializeViewController(with nibName:String) -> UIViewController {
//        let viewController = FreeUpSpaceViewController(nibName: nibName, bundle: nil)
//        let configurator = BaseFilesGreedModuleConfigurator()
//        let service = LocalPhotoAndVideoService()
//
//        configurator.configure(viewController: viewController,
//                               bottomBarConfig: nil,
//                               router: BaseFilesGreedRouter(),
//                               presenter: FreeUpSpacePresenter(),
//                               interactor: FreeUpSpaceInteractor(remoteItems: service),
//                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [],
//                                                                                     selectionModeTypes: []))
//
//        configurator.configure(viewController: viewController, remoteServices: PhotoAndVideoService(requestSize: 100),
//                               fileTypes: [.Video, .Photo],
//                               bottomBarConfig: bottomBarConfig, visibleSlider: true,
//                               topBarConfig: gridListTopBarConfig,
//                               alertSheetConfig: alertSheetConfig)
//
//        viewController.mainTitle = ""
//        return viewController
        
        
        let viewController = FreeUpSpaceViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.delete],
                                               style: .default, tintColor: nil)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: [.AlphaBetricAZ,.AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest],
            defaultSortType: .TimeNewOld,
            availableFilter: true,
            showGridListButton: true
        )
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select, .selectAll],
                                                                   selectionModeTypes: [.delete])
        
        configurator.configure(viewController: viewController, remoteServices: PhotoAndVideoService(requestSize: 100),
                               fileFilters: [.duplicates],
                               bottomBarConfig: bottomBarConfig, visibleSlider: true,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: alertSheetConfig)
        viewController.mainTitle = ""
        return viewController
    }
    
}
