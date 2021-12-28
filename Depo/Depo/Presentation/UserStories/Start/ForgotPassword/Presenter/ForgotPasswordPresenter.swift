//
//  ForgotPasswordForgotPasswordPresenter.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class ForgotPasswordPresenter: BasePresenter {
    weak var view: ForgotPasswordViewInput!
    var interactor: ForgotPasswordInteractorInput!
    var router: ForgotPasswordRouterInput!

    override func outputView() -> Waiting? {
        return view
    }

    private func removeBrackets(text: String) -> String {
        return text.filter { $0 != ")" && $0 != "(" }
    }
}

// MARK: - ForgotPasswordViewOutput
extension ForgotPasswordPresenter: ForgotPasswordViewOutput {
    func viewIsReady() {
        interactor.trackScreen()

        if interactor.isV2Enabled {
            view.setTexts(.new())
        } else {
            view.setTexts(.old())
        }
    }

    func userNavigatedBack() {
        interactor.trackBackEvent()
    }

    func startedEnteringPhoneNumber(withPlus: Bool) {
        if interactor.isV2Enabled {
            interactor.findCoutryPhoneCode(plus: withPlus)
        }
    }

    func resetPassword(withLogin login: String, enteredCaptcha: String, captchaUDID: String) {
        startAsyncOperationDisableScreen()
        interactor.sendForgotPasswordRequest(withLogin: removeBrackets(text: login),
                                             enteredCaptcha: enteredCaptcha, captchaUDID: captchaUDID)
    }
}

// MARK: - ForgotPasswordModuleInput
extension ForgotPasswordPresenter: ForgotPasswordModuleInput {}


// MARK: - ForgotPasswordInteractorOutput
extension ForgotPasswordPresenter: ForgotPasswordInteractorOutput {
    func foundCoutryPhoneCode(code: String, plus: Bool) {
        if plus {
            let countryCode = code.isEmpty ? "+" : code
            view.enterPhoneCountryCode(countryCode: countryCode)
        } else {
            view.insertPhoneCountryCode(countryCode: code)
        }
    }

    func linkSentToEmailSuccessfully() {
        completeAsyncOperationEnableScreen()
        router.showSentToEmailPopupAndClose()
    }

    func receivedVerificationMethods(_ methods: [IdentityVerificationMethod]) {
        completeAsyncOperationEnableScreen()
        router.proceedToIdentityVerification(service: interactor.resetPasswordService,
                                             availableMethods: methods)
    }

    func requestFailed(withError error: String) {
        completeAsyncOperationEnableScreen(errorMessage: error)
        view.showCapcha()
    }
}

private extension ForgotPasswordTexts {
    static func old() -> ForgotPasswordTexts {
        return ForgotPasswordTexts(
            instructions: TextConstants.resetPasswordInfo,
            emailInputTitle: TextConstants.resetPasswordEmailTitle,
            emailPlaceholder: TextConstants.resetPasswordEmailPlaceholder
        )
    }

    static func new() -> ForgotPasswordTexts {
        return ForgotPasswordTexts(
            instructions: localized(.resetPasswordInstructions),
            emailInputTitle: localized(.resetPasswordYourAccountEmail),
            emailPlaceholder: localized(.resetPasswordEnterYourAccountEmail)
        )
    }
}
