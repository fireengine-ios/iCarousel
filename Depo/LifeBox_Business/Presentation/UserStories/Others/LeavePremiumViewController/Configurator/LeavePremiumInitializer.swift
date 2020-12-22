//
//  LeavePremiumInitializer.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumModuleInitializer: NSObject {
    
    class func initializeLeavePremiumController(with nibName: String, type: LeavePremiumType) -> UIViewController {
        let viewController = LeavePremiumViewController(nibName: nibName, bundle: nil)
        let configurator = LeavePremiumModuleConfigurator()
        configurator.configure(viewController: viewController, type: type)
        
        return viewController
    }
    
}
