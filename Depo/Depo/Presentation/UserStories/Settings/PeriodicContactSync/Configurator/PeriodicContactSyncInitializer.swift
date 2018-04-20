//
//  PeriodicContactSyncInitializer.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PeriodicContactSyncInitializer: NSObject {
    
    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = PeriodicContactSyncViewController(nibName: nibName, bundle: nil)
        let configurator = PeriodicContactSyncConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
