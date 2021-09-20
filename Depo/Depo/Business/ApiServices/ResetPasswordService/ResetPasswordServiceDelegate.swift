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
                              receivedVerificationMethods methods: [IdentityVerificationMethod])
    func resetPasswordService(_ service: ResetPasswordService, verifiedWithMethod method: IdentityVerificationMethod)
    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error)
}

extension ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService,
                              receivedVerificationMethods methods: [IdentityVerificationMethod]) {}
    func resetPasswordService(_ service: ResetPasswordService, verifiedWithMethod method: IdentityVerificationMethod) {}
    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {}
}
