//
//  BottomSelectionTabBarBottomSelectionTabBarInitializer.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionTabBarModuleInitializer: NSObject {

    var presenter: BottomSelectionTabBarPresenter?
    var viewController: BottomSelectionTabBarViewController?
    
    func setupModule(config: EditingBarConfig, sourceView: UIView? = nil,
                     settablePresenter: BottomSelectionTabBarPresenter?) -> BottomSelectionTabBarViewController {
        presenter = settablePresenter
        let bottomTabBatVC = BottomSelectionTabBarViewController.initFromXib()
        let configurator = BottomSelectionTabBarModuleConfigurator()
        let interactor = BottomSelectionTabBarInteractor()
        let router = BottomSelectionTabBarRouter()
        configurator.configureModuleForViewInput(viewInput: bottomTabBatVC, presenter: presenter, interactor: interactor, router: router, config: config)
        viewController = bottomTabBatVC
        return bottomTabBatVC
    }
    
    func setupMusicModule(config: EditingBarConfig, sourceView: UIView? = nil,
                     settablePresenter: BottomSelectionTabBarPresenter?) -> BottomSelectionTabBarViewController {
        presenter = settablePresenter
        let bottomTabBatVC = BottomSelectionTabBarViewController.initFromXib()
        let configurator = BottomSelectionTabBarModuleConfigurator()
        let interactor = BottomSelectionMusicTabBarInteractor()
        let router = BottomSelectionMusicTabBarRouter()
        configurator.configureModuleForViewInput(viewInput: bottomTabBatVC, presenter: presenter, interactor: interactor, router: router, config: config)
        viewController = bottomTabBatVC
        return bottomTabBatVC
    }
}
