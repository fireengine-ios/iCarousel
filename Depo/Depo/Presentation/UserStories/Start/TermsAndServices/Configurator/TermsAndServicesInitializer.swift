//
//  TermsAndServicesTermsAndServicesInitializer.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesModuleInitializer: NSObject {
    
    weak var delegate: RegistrationViewDelegate?
    
    init(delegate: RegistrationViewDelegate?) {
        self.delegate = delegate
    }
    
    func setupConfig(withViewController controller: TermsAndServicesViewController,
                     fromLogin: Bool,
                     withSignUpSuccessResponse: SignUpSuccessResponse? = nil,
                     userInfo: RegistrationUserInfoModel? = nil,
                     phoneNumber: String?) {
        
        let configurator = TermsAndServicesModuleConfigurator(delegate: delegate)
        configurator.configureModuleForViewInput(viewInput: controller,
                                                 fromLogin: fromLogin,
                                                 phoneNumber: phoneNumber,
                                                 signUpSuccessResponse: withSignUpSuccessResponse,
                                                 userInfo: userInfo)
    }
    
}
