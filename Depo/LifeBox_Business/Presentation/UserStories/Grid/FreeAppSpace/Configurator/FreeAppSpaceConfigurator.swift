//
//  FreeAppSpaceFreeAppSpaceConfigurator.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpaceModuleConfigurator {

    func configure(viewController: FreeAppSpaceViewController, remoteServices: RemoteItemsService) {
        
//        let gridListTopBarConfig = GridListTopBarConfig(
//            defaultGridListViewtype: .Grid,
//            availableSortTypes: [.AlphaBetricAZ,.AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest],
//            defaultSortType: .TimeNewOld,
//            availableFilter: false,
//            showGridListButton: true
//        )
//
//        let gridListTopBar = GridListTopBar.initFromXib()
//        viewController.underNavBarBar = gridListTopBar
//        gridListTopBar.delegate = viewController
        
        let router = FreeAppSpaceRouter()
        
        let presenter = FreeAppSpacePresenter()
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.selectAll],
                                                                   selectionModeTypes: [.selectAll])
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        presenter.view = viewController
        presenter.router = router
        
        let interactor = FreeAppSpaceInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
