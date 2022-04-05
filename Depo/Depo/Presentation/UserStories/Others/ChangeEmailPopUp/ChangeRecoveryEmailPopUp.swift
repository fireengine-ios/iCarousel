//
//  ChangeRecoveryEmailPopUp.swift
//  Depo
//
//  Created by Hady on 3/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ChangeRecoveryEmailPopUp: BaseChangeEmailPopUp {
    private let analyticsService: AnalyticsService = factory.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsService.logScreen(screen: .changeRecoveryEmailPopUp)
    }

    override func cancelButtonPressed(_ sender: Any) {
        super.cancelButtonPressed(sender)
        analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                            eventActions: .changeEmail,
                                            eventLabel: .cancel)
    }

    override func updateEmail(email: String) {
        startActivityIndicator()

        let parameters = UserRecoveryEmailParameters(email: email)
        AccountService().updateUserRecoveryEmail(parameters: parameters, success: { [weak self] response in

            SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: {_ in
                DispatchQueue.main.async {
                    self?.stopActivityIndicator()
                    self?.backToVerificationPopup()
                }

                self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .emailChanged(isSuccessed: true))

            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.stopActivityIndicator()
                    self?.fail(error: error.description)
                }
            })
        }, fail: { [weak self] error in
            self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                      eventActions: .otp,
                                                      eventLabel: .emailChanged(isSuccessed: false),
                                                      errorType: GADementionValues.errorType(with: error.localizedDescription))

            DispatchQueue.main.async {
                self?.stopActivityIndicator()
                self?.fail(error: error.description)
            }
        })
    }
}
