//
//  IntroduceIntroduceInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol IntroduceInteractorOutput: AnyObject {
    func signUpRequired(for user: AppleGoogleUser)
    func passwordLoginRequired(for user: AppleGoogleUser)
    func continueWithAppleGoogleFailed(with error: AppleGoogeLoginError)
    func showTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse)
    func asyncOperationStarted()
    func signUpRequiredMessage(for user: AppleGoogleUser)
}
