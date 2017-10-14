//
//  ExpandStorageExpandStorageInitializer.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ExpandStorageModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var expandstorageViewController: ExpandStorageViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = ExpandStorageViewController(nibName: nibName, bundle: nil)
        let configurator = ExpandStorageModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
