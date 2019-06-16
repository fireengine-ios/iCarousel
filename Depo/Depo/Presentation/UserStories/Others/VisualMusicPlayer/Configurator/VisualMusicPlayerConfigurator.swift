//
//  VisualMusicPlayerVisualMusicPlayerConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleConfigurator {
    
    func configure(viewController: VisualMusicPlayerViewController, bottomBarConfig: EditingBarConfig) {

        let router = VisualMusicPlayerRouter()
        router.view = viewController

        let presenter = VisualMusicPlayerPresenter()
        presenter.view = viewController
        presenter.router = router
    
        // TODO: - Commented to clarify the exact requirements
//        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
//        let botvarBarVC = bottomBarVCmodule.setupMusicModule(config: bottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
//        viewController.editingTabBar = botvarBarVC
//        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
//        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        
        let interactor = VisualMusicPlayerInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
