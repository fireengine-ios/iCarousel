//
//  VisualMusicPlayerVisualMusicPlayerInitializer.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleInitializer: NSObject {

    lazy var visualmusicplayerViewController = VisualMusicPlayerViewController(nibName: "VisualMusicPlayerViewController", bundle: nil)

    override func awakeFromNib() {

        let configurator = VisualMusicPlayerModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .move, .delete],
                                               style: .blackOpaque, tintColor: nil)
        configurator.configureModuleForViewInput(viewInput: visualmusicplayerViewController, bottomBarConfig: bottomBarConfig)
    }
    
    func setupVC() {
        let configurator = VisualMusicPlayerModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .move, .delete],
                                               style: .blackOpaque, tintColor: nil)
        
        configurator.configureModuleForViewInput(viewInput: visualmusicplayerViewController, bottomBarConfig: bottomBarConfig)
    }

}
