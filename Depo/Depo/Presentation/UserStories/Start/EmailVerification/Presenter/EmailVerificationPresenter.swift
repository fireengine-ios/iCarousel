//
//  EmailVerificationPresenter.swift
//  Depo
//
//  Created by Hady on 1/18/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class EmailVerificationPresenter: PhoneVerificationPresenter, EmailVerificationInteractorOutput {
    var castedRouter: EmailVerificationRouterInput {
        return router as! EmailVerificationRouterInput
    }

    override var timerEnabled: Bool {
        return true
    }

    override func configure() {
        super.configure()
        view.setupPhoneLable(with: interactor.textDescription, number: interactor.email)
    }

    func emailVerified(signUpResponse: SignUpSuccessResponse) {
        guard let userInfo = SingletonStorage.shared.signUpInfo else {
            assertionFailure()
            return
        }

        castedRouter.phoneVerification(signUpResponse: signUpResponse, userInfo: userInfo)
    }

    func tooManyRequestsErrorReceievedForMSISDN(error: ServerValueError, signUpResponse: SignUpSuccessResponse) {
        guard let userInfo = SingletonStorage.shared.signUpInfo else {
            assertionFailure()
            return
        }

        castedRouter.phoneVerification(
            signUpResponse: signUpResponse, userInfo: userInfo, tooManyRequestsError: error
        )
    }
}
