//
//  TermsAndPolicyModuleInitializer.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class TermsAndPolicyModuleInitializer: NSObject {
    static var viewController: UIViewController {
        let nibName = String(describing: TermsAndPolicyViewController.self)
        let viewController = TermsAndPolicyViewController(nibName: nibName, bundle: nil)
        let configurator = TermsAndPolicyConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
    
    static func setupModule() -> UIViewController {
        let nibName = String(describing: TermsAndPolicyViewController.self)
        let viewController = TermsAndPolicyViewController(nibName: nibName, bundle: nil)
        let configurator = TermsAndPolicyConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
