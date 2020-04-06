//
//  AutoSyncAutoSyncInitializer.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncModuleInitializer: NSObject {
    
    class func initializeViewController(fromSettings: Bool = false) -> UIViewController {
        let viewController = AutoSyncViewController.initFromNib()
        let configurator = AutoSyncModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, fromSettings: fromSettings)
        return viewController
    }

}
