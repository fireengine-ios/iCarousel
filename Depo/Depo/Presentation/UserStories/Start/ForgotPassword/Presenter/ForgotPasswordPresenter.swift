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

    private func checkLanguage() {
        let langCode = Device.locale

        if langCode == "en" || langCode == "tr" {
            view.setupVisableSubTitle()
        }
    }

    private func removeBrackets(text: String) -> String {
        return text.filter { $0 != ")" && $0 != "(" }
    }
}

// MARK: - ForgotPasswordViewOutput
extension ForgotPasswordPresenter: ForgotPasswordViewOutput {
    func viewIsReady() {
        interactor.trackScreen()
        view.setupVisableTexts()
        #if LIFEBOX
            checkLanguage()
        #endif
    }

    func startedEnteringPhoneNumber(withPlus: Bool) {
        interactor.findCoutryPhoneCode(plus: withPlus)
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
