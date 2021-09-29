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

    private func showsTurkcellInstructions() -> Bool {
        #if LIFEBOX
        let langCode = Device.locale
        return langCode == "en" || langCode == "tr"
        #else
        return false
        #endif
    }

    private func removeBrackets(text: String) -> String {
        return text.filter { $0 != ")" && $0 != "(" }
    }
}

// MARK: - ForgotPasswordViewOutput
extension ForgotPasswordPresenter: ForgotPasswordViewOutput {
    func viewIsReady() {
        interactor.trackScreen()

        let isTurkcell = showsTurkcellInstructions()
        if interactor.isV2Enabled {
            view.setTexts(.new(isTurkcell: isTurkcell))
        } else {
            view.setTexts(.old(isTurkcell: isTurkcell))
        }
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
    static func old(isTurkcell: Bool) -> ForgotPasswordTexts {
        let turkcellInstructions = TextConstants.forgotPasswordSubTitle
        let instructionsOther = isTurkcell ? turkcellInstructions : TextConstants.resetPasswordSubTitle
        return ForgotPasswordTexts(
            instructions: TextConstants.resetPasswordInfo,
            instructionsOther: instructionsOther,
            emailInputTitle: TextConstants.resetPasswordEmailTitle,
            emailPlaceholder: TextConstants.resetPasswordEmailPlaceholder
        )
    }

    static func new(isTurkcell: Bool) -> ForgotPasswordTexts {
        let turkcellInstructions = TextConstants.forgotPasswordSubTitle
        let instructionsOther = isTurkcell ? turkcellInstructions : localized(.resetPasswordInstructionsOther)
        return ForgotPasswordTexts(
            instructions: localized(.resetPasswordInstructions),
            instructionsOther: instructionsOther,
            emailInputTitle: localized(.resetPasswordYourAccountEmail),
            emailPlaceholder: localized(.resetPasswordEnterYourAccountEmail)
        )
    }
}
