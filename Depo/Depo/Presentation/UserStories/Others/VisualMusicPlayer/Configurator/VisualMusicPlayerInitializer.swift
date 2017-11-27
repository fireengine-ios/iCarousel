//
//  VisualMusicPlayerVisualMusicPlayerInitializer.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VisualMusicPlayerModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var visualmusicplayerViewController: VisualMusicPlayerViewController!

    override func awakeFromNib() {

        let configurator = VisualMusicPlayerModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: visualmusicplayerViewController)
    }

}
