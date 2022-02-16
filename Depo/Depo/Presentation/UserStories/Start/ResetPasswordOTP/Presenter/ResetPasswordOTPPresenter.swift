//
//  ResetPasswordOTPPresenter.swift
//  Depo
//
//  Created by Hady on 9/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class ResetPasswordOTPPresenter: PhoneVerificationPresenter, ResetPasswordOTPInteractorOutput {

    override func userNavigatedBack() {
        (interactor as! ResetPasswordOTPInteractorInput).trackBackEvent()
    }

    override func viewIsReady() {
        interactor.trackScreen(isTimerExpired: false)
        view.setupInitialState(timerEnabled: timerEnabled)
        configure()
        view.setupButtonsInitialState()
        interactor.resendCode()
    }

    func verified(with resetPasswordService: ResetPasswordService, newMethods: [IdentityVerificationMethod]) {
        completeAsyncOperationEnableScreen()

        guard var viewControllers = view.getNavigationController()?.viewControllers else { return }
        viewControllers.removeLast() // remove PhoneVerificationViewController
        viewControllers.removeLast() // remove IdentityVerificationViewController

        let viewController = IdentityVerificationViewController(resetPasswordService: resetPasswordService,
                                                                availableMethods: newMethods)
        viewControllers.append(viewController)
        view.getNavigationController()?.setViewControllers(viewControllers, animated: true)
    }
}
