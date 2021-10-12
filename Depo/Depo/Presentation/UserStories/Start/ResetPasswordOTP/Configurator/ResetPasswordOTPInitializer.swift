//
//  ResetPasswordOTPModuleInitializer.swift
//  Depo
//
//  Created by Hady on 9/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class ResetPasswordOTPModuleInitializer {
    static func viewController(resetPasswordService: ResetPasswordService,
                               phoneNumber: String) -> PhoneVerificationViewController {
        let configurator = ResetPasswordOTPModuleConfigurator()

        let viewController = PhoneVerificationViewController()
        configurator.configure(viewController: viewController,
                               resetPasswordService: resetPasswordService, phoneNumber: phoneNumber)
        return viewController
    }
}
