//
//  VerifyRecoveryEmailPopUp.swift
//  Depo
//
//  Created by Hady on 9/7/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

final class VerifyRecoveryEmailPopUp: BaseEmailVerificationPopUp {

    override func viewDidLoad() {
        super.viewDidLoad()

        analyticsService.logScreen(screen: .verifyRecoveryEmailPopUp)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.VerifyRecoveryEmailPopUp())
    }

    override func setup() {
        super.setup()

        /// Send code once
        if !SingletonStorage.shared.isRecoveryEmailVerificationCodeSent {
            resendCode(isAutomaticaly: true)
        }
    }

    override func showPopUp() {
        super.showPopUp()

        analyticsService.logScreen(screen: .verifyRecoveryEmailPopUp)
    }

    override func onLaterTap(_ sender: Any) {
        super.onLaterTap(sender)

        analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                            eventActions: .otp,
                                            eventLabel: .later)
    }

    override var email: String {
        guard let email = SingletonStorage.shared.accountInfo?.recoveryEmail else {
            assertionFailure()
            return ""
        }

        return email
    }

    override var verificationRemainingDays: Int {
        return SingletonStorage.shared.accountInfo?.recoveryEmailVerificationRemainingDays ?? 0
    }

    override func createChangeEmailPopUp() -> BaseChangeEmailPopUp {
        return RouterVC().changeRecoveryEmailPopUp
    }

    override func verificationCodeEntered() {
        startActivityIndicator()

        accountService.verifyRecoveryEmail(otpCode: currentSecurityCode) { [weak self] response in
            self?.stopActivityIndicator()

            switch response {
            case .success:
                self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .confirmStatus(isSuccess: true))
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.RecoveryEmailVerification(action: .success))

                DispatchQueue.main.async { [weak self] in
                    self?.hidePopUp {
                        self?.showCompletedAndClose()
                    }
                }

            case .failed(let error):
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.RecoveryEmailVerification(action: .failure))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .confirmStatus(isSuccess: false),
                                                          errorType: GADementionValues.errorType(with: error.localizedDescription))

                DispatchQueue.main.async { [weak self] in
                    self?.showError(text: error.localizedDescription)
                    self?.clearCode()
                    self?.enableConfirmButtonIfNeeded()
                }
            }
        }
    }

    override func resendCode(isAutomaticaly: Bool = false) {
        startActivityIndicator()

        accountService.sendRecoveryEmailVerificationCode { [weak self] response in
            self?.stopActivityIndicator()

            switch response {
            case .success:
                if isAutomaticaly {
                    SingletonStorage.shared.isRecoveryEmailVerificationCodeSent = true
                } else {
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                              eventActions: .otp,
                                                              eventLabel: .codeResent(isSuccessed: true))
                }

            case .failed(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .recoveryEmailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .codeResent(isSuccessed: false),
                                                          errorType: GADementionValues.errorType(with: error.localizedDescription))

                DispatchQueue.main.async { [weak self] in
                    self?.clearCode()
                    self?.enableConfirmButtonIfNeeded()
                    self?.showError(text: error.localizedDescription)
                }
            }
        }
    }
}
