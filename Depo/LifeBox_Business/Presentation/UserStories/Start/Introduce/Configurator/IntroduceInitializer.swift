//
//  IntroduceIntroduceInitializer.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class IntroduceModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var introduceViewController: IntroduceViewController!

    override func awakeFromNib() {

        let configurator = IntroduceModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: introduceViewController)
    }
    
    func setupVC() {
        let configurator = IntroduceModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: introduceViewController)
        
    }

}
