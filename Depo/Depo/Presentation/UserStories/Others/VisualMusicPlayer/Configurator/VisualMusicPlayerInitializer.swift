//
//  VisualMusicPlayerVisualMusicPlayerInitializer.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleInitializer: NSObject {
    
    class func initializeVisualMusicPlayerController(with nibName: String) -> UIViewController {
        let viewController = VisualMusicPlayerViewController(nibName: nibName, bundle: nil)
        let configurator = VisualMusicPlayerModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .move, .moveToTrash],
                                               style: .blackOpaque, tintColor: nil)
        
        configurator.configure(viewController: viewController, bottomBarConfig: bottomBarConfig)
        
        return viewController
    }

}
