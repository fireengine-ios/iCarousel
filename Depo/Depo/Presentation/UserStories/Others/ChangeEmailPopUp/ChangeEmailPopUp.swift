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
    private lazy var appleGoogleService = AppleGoogleLoginService()
    var disconnectAppleGoogleLogin: Bool = false

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
                if self?.disconnectAppleGoogleLogin ?? false {
                    self?.removeAppleGoogleLogin(with: .apple)
                } else {
                    DispatchQueue.main.async {
                        self?.stopActivityIndicator()
                        self?.backToVerificationPopup()
                    }
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
    
    private func removeAppleGoogleLogin(with type: AppleGoogleUserType) {
        appleGoogleService.disconnectAppleGoogleLogin(type: type) { disconnect in
            switch disconnect {
            case .success:
                self.successDisconnect(with: type)
            case .preconditionFailed:
                self.successDisconnect(with: type)
            case .badRequest:
                self.hideSpinnerIncludeNavigationBar()
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    private func successDisconnect(with type: AppleGoogleUserType) {
        self.stopActivityIndicator()
        ItemOperationManager.default.appleGoogleLoginDisconnected(type: type)
        self.backToVerificationPopup()
    }
}
