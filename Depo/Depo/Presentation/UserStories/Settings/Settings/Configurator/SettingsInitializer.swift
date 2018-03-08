//
//  SettingsSettingsInitializer.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SettingsModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = SettingsViewController(nibName: nibName, bundle: nil)
        let configurator = SettingsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
