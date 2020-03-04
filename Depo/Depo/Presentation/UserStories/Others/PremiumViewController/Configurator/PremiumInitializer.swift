//
//  PremiumInitializer.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumModuleInitializer: NSObject {
    
    class func initializePremiumController(source: BecomePremiumView.SourceType, module: FaceImageItemsModuleOutput?, viewControllerForPresentOn: UIViewController?) -> UIViewController {
        let viewController = PremiumViewController.initFromNib()
        let configurator = PremiumModuleConfigurator()
        configurator.configure(viewController: viewController, source: source, module: module, viewControllerForPresentOn:viewControllerForPresentOn )
        
        return viewController
    }
    
}
