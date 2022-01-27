//
//  EmailVerificationInitializer.swift
//  Depo
//
//  Created by Hady on 1/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class EmailVerificationModuleInitializer: NSObject {
    static func viewController(signupResponse: SignUpSuccessResponse,
                               userInfo: RegistrationUserInfoModel) -> PhoneVerificationViewController {
        let configurator = EmailVerificationModuleConfigurator()

        let viewController = PhoneVerificationViewController()
        configurator.configure(viewController: viewController, withResponse: signupResponse, userInfo: userInfo)
        return viewController
    }
}
