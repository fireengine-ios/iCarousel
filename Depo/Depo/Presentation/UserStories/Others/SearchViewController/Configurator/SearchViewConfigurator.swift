//
//  SearchViewConfigurator.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewConfigurator {
    func configure(viewController: SearchViewController,
                   remoteServices: RemoteSearchService,
                   recentSearches: RecentSearchesService,
                   output: SearchModuleOutput?,
                   topBarConfig: GridListTopBarConfig?,
                   bottomBarConfig: EditingBarConfig?,
                   alertSheetConfig: AlertFilesActionsSheetInitialConfig?,
                   alertSheetExcludeTypes: [ElementTypes]? = nil) {
        
        let router = SeacrhViewRouter()
        
        let presenter = SearchViewPresenter()
        
        presenter.moduleOutput = output
        presenter.view = viewController
        presenter.router = router
        presenter.bottomBarConfig = bottomBarConfig
        
        if let alertSheetExcludeTypes = alertSheetExcludeTypes {
            presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        }
        
        if alertSheetConfig != nil {
            let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
            let alertModulePresenter = alertSheetModuleInitilizer.createModule()
            presenter.alertSheetModule = alertModulePresenter
            
            alertModulePresenter.basePassingPresenter = presenter
        }
        
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
        
        let interactor = SearchViewInteractor(remoteItems: remoteServices, recentSearches: recentSearches)
        interactor.output = presenter
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        viewController.needToShowTabBar = false
        viewController.floatingButtonsArray = [.takePhoto, .createAStory]
    }
}
