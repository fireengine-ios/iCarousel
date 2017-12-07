//
//  WelcomeWelcomeInitializer.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WelcomeModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var welcomeViewController: WelcomeViewController!
    
    class func initializeViewController(with nibName:String) -> WelcomeViewController {
        let viewController = WelcomeViewController(nibName: nibName, bundle: nil)
        let configurator = WelcomeModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
