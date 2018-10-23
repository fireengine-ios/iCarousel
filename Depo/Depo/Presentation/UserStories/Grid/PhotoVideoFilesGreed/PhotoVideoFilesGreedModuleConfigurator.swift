//
//  PhotoVideoFilesGreedModuleConfigurator.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PhotoVideoFilesGreedModuleConfigurator {
    func configure(viewController: PhotoVideoController,
                   moduleOutput: BaseFilesGreedModuleOutput? = nil,
                   remoteServices: RemoteItemsService,
                   fileFilters: [GeneralFilesFiltrationType],
                   bottomBarConfig: EditingBarConfig?,
                   visibleSlider: Bool = false,
                   visibleSyncItemsCheckBox: Bool = false,
                   topBarConfig: GridListTopBarConfig?,
                   alertSheetConfig: AlertFilesActionsSheetInitialConfig?,
                   alertSheetExcludeTypes: [ElementTypes]? = nil,
                   filedType: FieldValue) {
        
        let router = BaseFilesGreedRouter()
        
        
        let presenter = PhotoVideosFilesGreedPresenter(fieldType: filedType)
        presenter.needShowProgressInCells = true
        presenter.needShowScrollIndicator = false
        presenter.needShowEmptyMetaItems = true
        presenter.ifNeedReloadData = false
        
        
        if let alertSheetExcludeTypes = alertSheetExcludeTypes {
            presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        }
        presenter.bottomBarConfig = bottomBarConfig
        
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        presenter.moduleOutput = moduleOutput
        
        if let barConfig = bottomBarConfig {
            let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
            let botvarBarVC = bottomBarVCmodule.setupModule(config: barConfig, settablePresenter: BottomSelectionTabBarPresenter())
            viewController.editingTabBar = botvarBarVC
            presenter.bottomBarPresenter = bottomBarVCmodule.presenter
            bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        }
        if visibleSlider {
            let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
            let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
            sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter)
            let sliderVC = sliderModuleConfigurator.lbAlbumLikeSliderVC
            viewController.contentSlider = sliderVC
            presenter.sliderModule = sliderPresenter
            sliderPresenter.baseGreedPresenterModule = presenter
        }
        if visibleSyncItemsCheckBox {
            viewController.showOnlySyncItemsCheckBox = CheckBoxView.initFromXib()
        }
        if let underNavBarBarConfig = topBarConfig {
            presenter.topBarConfig = underNavBarBarConfig
            let gridListTopBar = GridListTopBar.initFromXib()
            viewController.underNavBarBar = gridListTopBar
            gridListTopBar.delegate = viewController
            
        }
        if alertSheetConfig != nil {
            let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
            let alertModulePresenter = alertSheetModuleInitilizer.createModule()
            presenter.alertSheetModule = alertModulePresenter
            
            alertModulePresenter.basePassingPresenter = presenter
        }
        
        let interactor = BaseFilesGreedInteractor(remoteItems: remoteServices)
        interactor.output = presenter
        
        interactor.originalFilters = fileFilters
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
