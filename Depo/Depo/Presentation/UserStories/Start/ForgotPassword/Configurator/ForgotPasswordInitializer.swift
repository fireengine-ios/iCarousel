//
//  ForgotPasswordForgotPasswordInitializer.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ForgotPasswordModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var forgotpasswordViewController: ForgotPasswordViewController!
    var loginText: String = ""

    override func awakeFromNib() {

        let configurator = ForgotPasswordModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: forgotpasswordViewController, loginText: loginText)
    }
    
    func setupVC() {
        let configurator = ForgotPasswordModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: forgotpasswordViewController, loginText: loginText)
    }

}
