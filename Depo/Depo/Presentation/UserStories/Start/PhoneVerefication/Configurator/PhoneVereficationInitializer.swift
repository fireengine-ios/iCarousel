//
//  PhoneVereficationPhoneVereficationInitializer.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var phonevereficationViewController: PhoneVerificationViewController!
    
    func setupConfig(with: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel ) {
        let configurator = PhoneVereficationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: phonevereficationViewController, withResponse: with, userInfo: userInfo)
    }
    
}
