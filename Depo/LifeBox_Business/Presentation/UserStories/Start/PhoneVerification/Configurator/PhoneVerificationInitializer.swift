//
//  PhoneVerificationModuleInitializer.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVerificationModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var phoneverificationViewController: PhoneVerificationViewController!
    
    func setupConfig(with: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel ) {
        let configurator = PhoneVerificationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: phoneverificationViewController, withResponse: with, userInfo: userInfo)
    }
    
}
