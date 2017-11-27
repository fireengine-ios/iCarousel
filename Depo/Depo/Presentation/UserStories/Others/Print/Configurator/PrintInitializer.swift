//
//  PrintInitializer.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintInitializer: NSObject {

    class func viewController(data: [Item]) -> UIViewController {
        let nibName = String(describing: PrintViewController.self)
        let viewController = PrintViewController(nibName: nibName, bundle: nil)
        let configurator = PrintModuleConfigurator()
        configurator.configure(viewController: viewController, data: data)
        return viewController
    }
    
}
