//
//  ManageContactsInitializer.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ManageContactsModuleInitializer: NSObject {

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = ManageContactsViewController(nibName: nibName, bundle: nil)
        let configurator = ManageContactsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
