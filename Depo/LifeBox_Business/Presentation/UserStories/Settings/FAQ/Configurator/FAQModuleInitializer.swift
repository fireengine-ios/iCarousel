//
//  FAQModuleInitializer.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FAQModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var faqViewController: FAQViewController!

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = FAQViewController()
        let configurator = FAQModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
