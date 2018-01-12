//
//  TurkcellSecurityTurkcellSecurityInitializer.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TurkcellSecurityModuleInitializer: NSObject {
    static var viewController: UIViewController {
        let nibName = String(describing: TurkcellSecurityViewController.self)
        let viewController = TurkcellSecurityViewController(nibName: nibName, bundle: nil)
        let configurator = TurkcellSecurityModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
    
//    static func installModule(inNeedOfMail: Bool) -> UIViewController {
//        let nibName = String(describing: TurkcellSecurityViewController.self)
//        let viewController = TurkcellSecurityViewController(nibName: nibName, bundle: nil)
//        let configurator = TurkcellSecurityModuleConfigurator()
//        configurator.configureModuleForViewInput(viewInput: viewController, inNeedOfMail: inNeedOfMail)
//        return viewController
//    }
}
