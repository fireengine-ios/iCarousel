//
//  SplashSplashInitializer.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SplashModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var splashViewController: SplashViewController!

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = SplashViewController(nibName: nibName, bundle: nil)
        let configurator = SplashModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
