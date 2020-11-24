//
//  FreeAppSpaceFreeAppSpaceInitializer.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpaceModuleInitializer: NSObject {
   
    class func initializeFreeAppSpaceViewController(with nibName: String) -> UIViewController {
        let viewController = FreeAppSpaceViewController(nibName: nibName, bundle: nil)
        
        viewController.scrollablePopUpsMediator.cardProtocolSupportedView.isEnable = false
        
        let configurator = FreeAppSpaceModuleConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: FreeAppService())
        return viewController
    }
    
}
