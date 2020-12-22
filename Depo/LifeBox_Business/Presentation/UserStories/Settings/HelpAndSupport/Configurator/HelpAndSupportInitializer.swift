//
//  HelpAndSupportHelpAndSupportInitializer.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HelpAndSupportModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var helpandsupportViewController: HelpAndSupportViewController!

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = HelpAndSupportViewController()
        let configurator = HelpAndSupportModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
