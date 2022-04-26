//
//  LoginLoginInitializer.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LoginModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var loginViewController: LoginViewController!

    override func awakeFromNib() {
        let configurator = LoginModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: loginViewController)
    }
    
    func setupVC() {
        let configurator = LoginModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: loginViewController)
    }
    
    func setupVC(with user: AppleGoogleUser) {
        let configurator = LoginModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: loginViewController, user: user)
    }
    
    func setupVC(with user: AppleGoogleUser, headers: [String:Any]) {
        let configurator = LoginModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: loginViewController, user: user, headers: headers)
    }

}
