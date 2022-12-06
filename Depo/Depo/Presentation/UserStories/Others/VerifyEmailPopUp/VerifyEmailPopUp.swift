//
//  VerifyEmailPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class VerifyEmailPopUp: BaseEmailVerificationPopUp {

    override func viewDidLoad() {
        super.viewDidLoad()

        analyticsService.logScreen(screen: .verifyEmailPopUp)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.VerifyEmailPopUp())
    }
    
    override func setup() {
        super.setup()
        
        ///don't send code if just registered(code already sent)
        if SingletonStorage.shared.isNeedToSentEmailVerificationCode {
            resendCode(isAutomaticaly: true)
        }
    }

    override func showPopUp() {
        super.showPopUp()

        analyticsService.logScreen(screen: .verifyEmailPopUp)
    }
    

    override func onChangeEmailTap(_ sender: Any) {
        super.onChangeEmailTap(sender)

        analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                            eventActions: .otp,
                                            eventLabel: .changeEmail)
    }
    
    override func onLaterTap(_ sender: Any) {
        super.onLaterTap(sender)

        analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                            eventActions: .otp,
                                            eventLabel: .later)
        isRecoveryNeedToOpen()
    }
    
    private func isRecoveryNeedToOpen() {
        if SingletonStorage.shared.isJustRegistered == nil || SingletonStorage.shared.isJustRegistered == false {

            SingletonStorage.shared.securityInfoIfNeeded { isNeed in
                if isNeed {
                    RouterVC().securityInfoViewController(fromSettings: false)
                }
            }
        }
    }

    override var email: String {
        guard let email = SingletonStorage.shared.accountInfo?.email else {
            assertionFailure()
            return ""
        }

        return email
    }

    override var verificationRemainingDays: Int {
        return SingletonStorage.shared.accountInfo?.emailVerificationRemainingDays ?? 0
    }

    override func createChangeEmailPopUp() -> BaseChangeEmailPopUp {
        return RouterVC().changeEmailPopUp
    }

    override func verificationCodeEntered() {
        startActivityIndicator()

        accountService.verifyEmail(otpCode: currentSecurityCode) { [weak self] response in
            self?.stopActivityIndicator()

            switch response {
            case .success(_):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .confirmStatus(isSuccess: true))
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EmailVerification(action: .success))
                DispatchQueue.main.async { [weak self] in
                    self?.hidePopUp {
                        self?.showCompletedAndClose()
                    }
                }

            case .failed(let error):
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EmailVerification(action: .failure))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
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

       accountService.sendEmailVerificationCode { [weak self] response in
           self?.stopActivityIndicator()

           switch response {
           case .success(_):
               if isAutomaticaly {
                   SingletonStorage.shared.isEmailVerificationCodeSent = true
               } else {
                   self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                             eventActions: .otp,
                                                             eventLabel: .codeResent(isSuccessed: true))
               }

               break
           case .failed(let error):
               self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
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
