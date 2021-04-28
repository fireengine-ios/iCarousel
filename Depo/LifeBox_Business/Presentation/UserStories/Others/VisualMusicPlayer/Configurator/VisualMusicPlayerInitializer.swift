//
//  VisualMusicPlayerVisualMusicPlayerInitializer.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleInitializer: NSObject {
    
    class func initializeVisualMusicPlayerController(with nibName: String, status: ItemStatus) -> UIViewController {
        let viewController = VisualMusicPlayerViewController(nibName: nibName, bundle: nil)
        let configurator = VisualMusicPlayerModuleConfigurator()
        configurator.configure(viewController: viewController, status: status)
        
        return viewController
    }

}
