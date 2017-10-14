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
        configurator.configureModuleForViewInput(viewInput: bottomTabBatVC, presenter: presenter, config: config)
        viewController = bottomTabBatVC
        return bottomTabBatVC
    }
    
}
