//
//  PasscodeSettingsPasscodeSettingsInitializer.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PasscodeSettingsModuleInitializer: NSObject {
    static var viewController: UIViewController {
        let nibName = String(describing: PasscodeSettingsViewController.self)
        let viewController = PasscodeSettingsViewController(nibName: nibName, bundle: nil)
        let configurator = PasscodeSettingsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, inNeedOfMail: false)
        return viewController
    }
    
    static func setupModule(inNeedOfMail: Bool) -> UIViewController {
        let nibName = String(describing: PasscodeSettingsViewController.self)
        let viewController = PasscodeSettingsViewController(nibName: nibName, bundle: nil)
        let configurator = PasscodeSettingsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, inNeedOfMail: inNeedOfMail)
        return viewController
    }
}
