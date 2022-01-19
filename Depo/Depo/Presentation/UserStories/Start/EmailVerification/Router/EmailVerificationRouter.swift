//
//  EmailVerificationRouter.swift
//  Depo
//
//  Created by Hady on 1/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol EmailVerificationRouterInput: PhoneVerificationRouterInput {
    func phoneVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)
}

final class EmailVerificationRouter: PhoneVerificationRouter, EmailVerificationRouterInput {
    func phoneVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        let phoneVerification = router.phoneVerificationScreen(signUpResponse: signUpResponse, userInfo: userInfo)
        router.replaceTopViewControllerWithViewController(phoneVerification)
    }
}
