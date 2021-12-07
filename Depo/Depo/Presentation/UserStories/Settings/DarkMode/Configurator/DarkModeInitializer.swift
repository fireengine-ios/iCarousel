//
//  DarkModeInitializer.swift
//  Depo
//
//  Created by Burak Donat on 6.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

class DarkModeInitializer: NSObject {

    class func initializeViewController() -> UIViewController {
        let nibName = String(describing: DarkModeViewController.self)
        let viewController = DarkModeViewController(nibName: nibName, bundle: nil)
        let configurator = DarkModeConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
