//
//  PhoneVerificationModuleInitializer.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PhoneVerificationModuleInitializer: NSObject {
    static func viewController(signupResponse: SignUpSuccessResponse,
                               userInfo: RegistrationUserInfoModel,
                               tooManyRequestsError: ServerValueError? = nil) -> PhoneVerificationViewController {
        let configurator = PhoneVerificationModuleConfigurator()

        let viewController = PhoneVerificationViewController()
        configurator.configure(
            viewController: viewController,
            withResponse: signupResponse,
            userInfo: userInfo,
            tooManyRequestsError: tooManyRequestsError
        )
        return viewController
    }
}
