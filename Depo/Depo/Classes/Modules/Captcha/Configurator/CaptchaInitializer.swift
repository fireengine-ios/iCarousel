//
//  CaptchaCaptchaInitializer.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CaptchaModuleInitializer: NSObject {

    //Connect with object on storyboard
//    @IBOutlet weak
    var captchaViewController: CaptchaViewController!

    
    func setupModule() {
        let configurator = CaptchaModuleConfigurator()
        captchaViewController = CaptchaViewController.initFromXib()
        configurator.configureModuleForViewInput(viewInput: captchaViewController)
    }
}
