//
//  ChangeEmailPopUp.swift
//  Depo
//
//  Created by Hady on 3/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ChangeEmailPopUp: BaseChangeEmailPopUp {
    private let analyticsService: AnalyticsService = factory.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsService.logScreen(screen: .changeEmailPopUp)
    }

    override func cancelButtonPressed(_ sender: Any) {
        super.cancelButtonPressed(sender)
        analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                            eventActions: .changeEmail,
                                            eventLabel: .cancel)
    }

    override func updateEmail(email: String) {
        startActivityIndicator()

        let parameters = UserEmailParameters(userEmail: email)
        AccountService().updateUserEmail(parameters: parameters, success: { [weak self] response in

            SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: {_ in
                DispatchQueue.main.async {
                    self?.stopActivityIndicator()
                    self?.backToVerificationPopup()
                }

                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .emailChanged(isSuccessed: true))

            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.stopActivityIndicator()
                    self?.fail(error: error.description)
                }
            })
        }, fail: { [weak self] error in
            self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
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
