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
        configurator.configureModuleForViewInput(viewInput: viewController, isTurkcell: false, inNeedOfMail: false)
        return viewController
    }
    
    static func setupModule(isTurkcell: Bool, inNeedOfMail: Bool) -> UIViewController {
        let nibName = String(describing: PasscodeSettingsViewController.self)
        let viewController = PasscodeSettingsViewController(nibName: nibName, bundle: nil)
        let configurator = PasscodeSettingsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)
        return viewController
    }
}
