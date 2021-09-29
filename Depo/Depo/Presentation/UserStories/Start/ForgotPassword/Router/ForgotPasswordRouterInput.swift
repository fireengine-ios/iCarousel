//
//  ForgotPasswordForgotPasswordRouterInput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ForgotPasswordRouterInput {
    func showSentToEmailPopupAndClose()
    func proceedToIdentityVerification(service: ResetPasswordService,
                                       availableMethods: [IdentityVerificationMethod])
    func popBack()
}
