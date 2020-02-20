//
//  LoginSettingsModuleInitializer.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LoginSettingsModuleInitializer: NSObject {
    static func viewController(isTurkcell: Bool) -> UIViewController {
        let nibName = String(describing: LoginSettingsViewController.self)
        let viewController = LoginSettingsViewController(nibName: nibName, bundle: nil)
        let configurator = LoginSettingsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, isTurkcell: isTurkcell)
        return viewController
    }
    
//    static func installModule(inNeedOfMail: Bool) -> UIViewController {
//        let nibName = String(describing: TurkcellSecurityViewController.self)
//        let viewController = TurkcellSecurityViewController(nibName: nibName, bundle: nil)
//        let configurator = LoginSettingsModuleConfigurator()
//        configurator.configureModuleForViewInput(viewInput: viewController, inNeedOfMail: inNeedOfMail)
//        return viewController
//    }
}
