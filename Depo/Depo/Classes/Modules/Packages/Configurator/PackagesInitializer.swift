//
//  PackagesPackagesInitializer.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesModuleInitializer: NSObject {

    static var viewController: PackagesViewController {
        let nibName = String(describing: PackagesViewController.self)
        let viewController = PackagesViewController(nibName: nibName, bundle: nil)
        let configurator = PackagesModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
