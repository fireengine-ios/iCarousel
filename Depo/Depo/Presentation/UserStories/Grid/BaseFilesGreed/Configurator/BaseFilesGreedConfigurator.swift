//
//  BaseFilesGreedConfigurator.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedModuleConfigurator {
    
    func configure(viewController: BaseFilesGreedViewController,
                   moduleOutput: BaseFilesGreedModuleOutput? = nil,
                   remoteServices: RemoteItemsService,
                   fileFilters: [GeneralFilesFiltrationType],
                   bottomBarConfig: EditingBarConfig?,
                   visibleSlider: Bool = false,
                   visibleSyncItemsCheckBox: Bool = false,
                   topBarConfig: GridListTopBarConfig?,
                   alertSheetConfig: AlertFilesActionsSheetInitialConfig?,
                   alertSheetExcludeTypes: [ElementTypes]? = nil) {
        
        let router = BaseFilesGreedRouter()
        router.view = viewController
        
        var presenter: BaseFilesGreedPresenter?
        if remoteServices is PhotoAndVideoService {
            presenter = BaseFilesGreedPresenter()
            presenter?.needShowProgressInCells = true
            presenter?.needShowScrollIndicator = true
            presenter?.needShowEmptyMetaItems = true
            presenter?.ifNeedReloadData = false
        } else {
            presenter = DocumentsGreedPresenter()
            presenter?.sortedRule = .timeUpWithoutSection
        }
        
        if let alertSheetExcludeTypes = alertSheetExcludeTypes {
            presenter?.alertSheetExcludeTypes = alertSheetExcludeTypes
        }
        presenter?.bottomBarConfig = bottomBarConfig
        
        presenter!.view = viewController
        presenter!.router = router
        router.presenter = presenter
        presenter?.moduleOutput = moduleOutput
        
        if let barConfig = bottomBarConfig {
            let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
            let botvarBarVC = bottomBarVCmodule.setupModule(config: barConfig, settablePresenter: BottomSelectionTabBarPresenter())
            viewController.editingTabBar = botvarBarVC
            presenter?.bottomBarPresenter = bottomBarVCmodule.presenter
            bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        }
        if visibleSlider {
            let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
            let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
            sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter)
            let sliderVC = sliderModuleConfigurator.lbAlbumLikeSliderVC
            viewController.contentSlider = sliderVC
            presenter?.sliderModule = sliderPresenter
            sliderPresenter.baseGreedPresenterModule = presenter
        }
        if visibleSyncItemsCheckBox {
            viewController.showOnlySyncItemsCheckBox = CheckBoxView.initFromNib()
        }
        if let underNavBarBarConfig = topBarConfig {
            presenter?.topBarConfig = underNavBarBarConfig
            let gridListTopBar = GridListTopBar.initFromXib()
            viewController.underNavBarBar = gridListTopBar
            gridListTopBar.delegate = viewController
            
        }
        if alertSheetConfig != nil {
            let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
            let alertModulePresenter = alertSheetModuleInitilizer.createModule()
            presenter?.alertSheetModule = alertModulePresenter
            
            alertModulePresenter.basePassingPresenter = presenter
        }
        
        let interactor = BaseFilesGreedInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        
        interactor.originalFilters = fileFilters
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter!.interactor = interactor
        viewController.output = presenter
    }
    
    func configure(viewController: BaseFilesGreedViewController, folder: Item, remoteServices: RemoteItemsService) {
        
        let router = BaseFilesGreedRouter()
        router.view = viewController
        
        let presenter: BaseFilesGreedPresenter = DocumentsGreedPresenter()
        
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        
        let interactor = BaseFilesGreedInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        interactor.folder = folder
        interactor.parent = folder
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
    
    func configure(viewController: BaseFilesGreedViewController, fileFilters: [GeneralFilesFiltrationType]? = nil,
                   bottomBarConfig: EditingBarConfig?, router: BaseFilesGreedRouter,
                   presenter: BaseFilesGreedPresenter, interactor: BaseFilesGreedInteractor,
                   alertSheetConfig: AlertFilesActionsSheetInitialConfig?,
                   topBarConfig: GridListTopBarConfig?) {
        
        presenter.bottomBarConfig = bottomBarConfig
        
        presenter.view = viewController
        presenter.router = router
        router.view = viewController
        router.presenter = presenter
        
        if let barConfig = bottomBarConfig {
            let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
            let botvarBarVC = bottomBarVCmodule.setupModule(config: barConfig, settablePresenter: BottomSelectionTabBarPresenter())
            
            viewController.editingTabBar = botvarBarVC
            presenter.bottomBarPresenter = bottomBarVCmodule.presenter
            bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        }
        if alertSheetConfig != nil {
            let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
            let alertModulePresenter = alertSheetModuleInitilizer.createModule()
            presenter.alertSheetModule = alertModulePresenter
            alertModulePresenter.basePassingPresenter = presenter
        }
        
        if let underNavBarBarConfig = topBarConfig {
            presenter.topBarConfig = underNavBarBarConfig
            let gridListTopBar = GridListTopBar.initFromXib()
            viewController.underNavBarBar = gridListTopBar
            gridListTopBar.delegate = viewController
            
        }
        
        if let uploadInteracotor = interactor as? UploadFilesSelectionInteractor {
            uploadInteracotor.uploadOutput = presenter as? UploadFilesSelectionPresenter
        }
        
        interactor.originalFilters = fileFilters
        
        interactor.output = presenter
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
