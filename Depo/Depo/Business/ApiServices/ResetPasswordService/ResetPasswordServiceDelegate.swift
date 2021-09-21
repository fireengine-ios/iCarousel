//
//  ResetPasswordServiceDelegate.swift
//  Depo
//
//  Created by Hady on 9/20/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol ResetPasswordServiceDelegate: AnyObject {
    func resetPasswordService(_ service: ResetPasswordService,
                              resetBeganWithMethods methods: [IdentityVerificationMethod])
    func resetPasswordService(_ service: ResetPasswordService, readyToProceedWithMethod method: IdentityVerificationMethod)
    func resetPasswordService(_ service: ResetPasswordService, receivedOTPResponse response: ResetPasswordResponse)
    func resetPasswordService(_ service: ResetPasswordService, phoneVerified newMethods: [IdentityVerificationMethod])
    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error)
}

extension ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService,
                              resetBeganWithMethods methods: [IdentityVerificationMethod]) {}
    func resetPasswordService(_ service: ResetPasswordService, readyToProceedWithMethod method: IdentityVerificationMethod) {}
    func resetPasswordService(_ service: ResetPasswordService, receivedOTPResponse response: ResetPasswordResponse) {}
    func resetPasswordService(_ service: ResetPasswordService, phoneVerified newMethods: [IdentityVerificationMethod]) {}
    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {}
}
