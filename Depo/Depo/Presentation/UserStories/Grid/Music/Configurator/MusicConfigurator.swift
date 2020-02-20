//
//  MusicConfigurator.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class MusicConfigurator {
    
    func configure(viewController: MusicViewController,
                   remoteServices: RemoteItemsService,
                   fileFilters: [GeneralFilesFiltrationType],
                   bottomBarConfig: EditingBarConfig?,
                   topBarConfig: GridListTopBarConfig?,
                   alertSheetConfig: AlertFilesActionsSheetInitialConfig?) {
        let router = BaseFilesGreedRouter()
        router.view = viewController
        
        let presenter = MusicPresenter()
        presenter.sortedRule = .timeUpWithoutSection
        
        presenter.bottomBarConfig = bottomBarConfig
        
        if let barConfig = bottomBarConfig {
            let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
            let botvarBarVC = bottomBarVCmodule.setupModule(config: barConfig, settablePresenter: BottomSelectionTabBarPresenter())
            viewController.editingTabBar = botvarBarVC
            presenter.bottomBarPresenter = bottomBarVCmodule.presenter
            bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        }
        
        if let underNavBarBarConfig = topBarConfig {
            presenter.topBarConfig = underNavBarBarConfig
            let gridListTopBar = GridListTopBar.initFromXib()
            viewController.underNavBarBar = gridListTopBar
            gridListTopBar.delegate = viewController
            
        }
        
        presenter.view = viewController
        presenter.router = router
        router.presenter = presenter
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
            
        alertModulePresenter.basePassingPresenter = presenter
        
        var spotifyService: SpotifyRoutingService = factory.resolve()

        let interactor = MusicInteractor(remoteItems: remoteServices, spotifyService: spotifyService)
        interactor.output = presenter
        
        interactor.originalFilters = fileFilters
        
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
