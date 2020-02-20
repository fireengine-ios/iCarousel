//
//  PremiumInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumModuleInitializer: NSObject {
    
    class func initializePremiumController(with nibName: String, title: String, headerTitle: String, module: FaceImageItemsModuleOutput?, viewControllerForPresentOn: UIViewController?) -> UIViewController {
        let viewController = PremiumViewController(nibName: nibName, bundle: nil)
        let configurator = PremiumModuleConfigurator()
        configurator.configure(viewController: viewController, title: title, headerTitle: headerTitle, module: module, viewControllerForPresentOn:viewControllerForPresentOn )
        
        return viewController
    }
    
}
