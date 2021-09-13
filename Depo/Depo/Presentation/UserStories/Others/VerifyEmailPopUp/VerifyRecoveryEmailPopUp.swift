//
//  VerifyRecoveryEmailPopUp.swift
//  Depo
//
//  Created by Hady on 9/7/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

final class VerifyRecoveryEmailPopUp: BaseEmailVerificationPopUp {

    override func setup() {
        super.setup()
        // No need for change email button for recovery email
        changeEmailButton.isHidden = true

        laterButton.isHidden = false

        /// Send code once
        if !SingletonStorage.shared.isRecoveryEmailVerificationCodeSent {
            resendCode(isAutomaticaly: true)
        }
    }

    override var email: String {
        guard let email = SingletonStorage.shared.accountInfo?.recoveryEmail else {
            assertionFailure()
            return ""
        }

        return email
    }

    override func verificationCodeEntered() {
        startActivityIndicator()

        accountService.verifyRecoveryEmail(otpCode: currentSecurityCode) { [weak self] response in
            self?.stopActivityIndicator()

            switch response {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    self?.hidePopUp {
                        self?.showCompletedAndClose()
                    }
                }

            case .failed(let error):
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
                }

            case .failed(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.clearCode()
                    self?.enableConfirmButtonIfNeeded()
                    self?.showError(text: error.localizedDescription)
                }
            }
        }
    }
}
