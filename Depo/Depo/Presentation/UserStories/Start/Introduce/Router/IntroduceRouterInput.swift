//
//  IntroduceIntroduceRouterInput.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol IntroduceRouterInput {
    func onGoToRegister()
    func onGoToLogin()
    func onGoToLoginWith(with user: GoogleUser)
    func onGoToRegister(with user: GoogleUser)
    func goToLoginWithHeaders(with user: GoogleUser, headers: [String : Any])
    func goToTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse)
}
