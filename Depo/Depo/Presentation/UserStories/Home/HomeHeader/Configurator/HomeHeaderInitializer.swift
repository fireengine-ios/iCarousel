//
//  HomeHeaderHomeHeaderInitializer.swift
//  Depo
//
//  Created by Oleg on 28/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomeHeaderModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var homeheaderViewController: HomeHeaderViewController!

    override func awakeFromNib() {

        let configurator = HomeHeaderModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: homeheaderViewController)
    }

}
