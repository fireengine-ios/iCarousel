//
//  MyStorageModuleInitializer.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class MyStorageModuleInitializer: NSObject {
    
    class func initializeMyStorageController(usage: UsageResponse?, affiliate: String? = nil, refererToken: String? = nil) -> MyStorageViewController {
        let nibName = String(describing: MyStorageViewController.self)
        let viewController = MyStorageViewController(nibName: nibName, bundle: nil)
        let configurator = MyStorageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, usage: usage, affiliate: affiliate, refererToken: refererToken)
        return viewController
    }
}
