//
//  OTPViewOTPViewInitializer.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class OTPViewModuleInitializer: NSObject {
        
    class func viewController(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse, phoneNumber: String) -> UIViewController {
        let nibName = "PhoneVereficationScreen"
        let viewController = PhoneVereficationViewController(nibName: nibName, bundle: nil)
        let configurator = OTPViewModuleConfigurator()
        configurator.configure(viewController: viewController, responce: responce, userInfo: userInfo, phoneNumber: phoneNumber)
        return viewController
    }
    
}
