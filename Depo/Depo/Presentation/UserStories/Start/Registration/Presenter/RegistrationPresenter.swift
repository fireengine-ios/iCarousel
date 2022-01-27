//
//  RegistrationRegistrationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import UIKit

class RegistrationPresenter: BasePresenter {
    
    weak var view: RegistrationViewInput!
    var interactor: RegistrationInteractorInput!
    var router: RegistrationRouterInput!

    var isSupportFormPresenting: Bool = false
    var eulaText: String?

    private var confirmAgreements = false
    private var confirmEtk: Bool?
    private var confirmGlobalPerm: Bool?
    
    // MARK: BasePresenter
    override func outputView() -> Waiting? {
        return view
    }

    private func updateNextButtonStatus() {
        view?.setNextButtonEnabled(confirmAgreements)
    }
}

// MARK: - RegistrationViewOutput
extension RegistrationPresenter: RegistrationViewOutput {
    func viewIsReady() {
        interactor.trackScreen()
        startAsyncOperation()
        interactor.checkCaptchaRequerement()
        updateNextButtonStatus()
        interactor.loadTermsOfUse()
    }
    
    func prepareCaptcha(_ view: CaptchaView) {
        view.delegate = self
    }
    
    func nextButtonPressed() {
        view.collectInputedUserInfo()
    }

    func validatePassword(_ password: String, repassword: String?) {
        interactor.validatePassword(password, repassword: repassword)
    }
    
    func collectedUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?) {
        interactor.validateUserInfo(email: email.replacingOccurrences(of: " ", with: ""),
                                    code: code, phone: phone,
                                    password: password, repassword: repassword,
                                    captchaID: captchaID, captchaAnswer: captchaAnswer)
    }
    
    func openSupport() {
        isSupportFormPresenting = true
        router.openSupport()
    }
    
    func openFaqSupport() {
        isSupportFormPresenting = true
        router.goToFaqSupportPage()
    }
    
    func openSubjectDetails(type: SupportFormSubjectTypeProtocol) {
        interactor.trackSupportSubjectEvent(type: type)
        isSupportFormPresenting = true
        router.goToSubjectDetailsPage(type: type)
    }

    func phoneNumberChanged(_ code: String, _ phone: String) {
        interactor.checkEtkAndGlobalPermissions(code: code, phone: phone)
    }

    func confirmTermsOfUse(_ confirm: Bool) {
        confirmAgreements = confirm
        updateNextButtonStatus()
        interactor.trackEULAConfirmed()
    }

    func confirmEtk(_ etk: Bool) {
        confirmEtk = etk
        updateNextButtonStatus()
    }

    func openPrivacyPolicyDescriptionController() {
        router.goToPrivacyPolicyDescriptionController()
    }
}

// MARK: - RegistrationInteractorOutput
extension RegistrationPresenter: RegistrationInteractorOutput {
    func checkPasswordRuleValid(for result: [UserValidationResults]) {
        if !result.contains(where: [.passwordBelowMinimumLength,
                                   .passwordExceedsMaximumLength,
                                   .passwordIsEmpty].contains) {
            view.validatePasswordRules(forType: .characterLimitRule)
        }

        if !result.contains(where: [.passwordMissingUppercase,
                                   .passwordMissingLowercase,
                                   .passwordMissingNumbers,
                                   .passwordIsEmpty].contains) {
            view.validatePasswordRules(forType: .capitalizationAndNumberRule)
        }

        if !result.contains(where: [.passwordExceedsSequentialCharactersLimit,
                                   .passwordExceedsSameCharactersLimit,
                                   .passwordIsEmpty].contains) {
            view.validatePasswordRules(forType: .sequentialRule)
        }
    }

    func userValid(_ userInfo: RegistrationUserInfoModel) {
        guard confirmAgreements else {
            view?.showErrorTitle(withText: TextConstants.termsAndUseCheckboxErrorText)
            return
        }

        startAsyncOperationDisableScreen()
        interactor.signUpUser(userInfo, etkAuth: confirmEtk, globalPermAuth: confirmGlobalPerm)
    }
    
    func userInvalid(withResult result: [UserValidationResults]) {
        result.forEach { errorType in
            view.showInfoButton(forType: errorType)
        }
    }
    
    func signUpFailed(errorResponse: Error) {
        completeAsyncOperationEnableScreen()
        
        if (errorResponse as? SignupResponseError)?.isCaptchaError == true {
            view.showCaptchaError(TextConstants.loginScreenInvalidCaptchaError)
        } else {
            view.showErrorTitle(withText: errorResponse.description)
        }
        
        if interactor.captchaRequired {
            view.updateCaptcha()
        }
    }
    
    func signUpSucceeded(userInfo: RegistrationUserInfoModel, proceed: @escaping () -> Void) {
        completeAsyncOperationEnableScreen()

        interactor.trackEmailUsagePopUp()
        router.presentEmailUsagePopUp(email: userInfo.mail) { [weak self] in
            self?.startAsyncOperationDisableScreen()
            proceed()
        }
    }

    func verificationCodeSent(userInfo: RegistrationUserInfoModel, response: SignUpSuccessResponse) {
        completeAsyncOperationEnableScreen()
        if response.actionIs(.continueWithEmailVerification) {
            router.emailVerification(signUpResponse: response, userInfo: userInfo)
        } else {
            if !response.actionIs(.continueWithOTPVerification) {
                debugLog("WARNING: signup received unrecognized action \(response.action ?? "")")
            }
            router.phoneVerification(signUpResponse: response, userInfo: userInfo)
        }
    }

    func captchaRequired(required: Bool) {
        if required {
            view.setupCaptcha()
        }
        asyncOperationSuccess()
    }
    
    func captchaRequiredFailed() {
        asyncOperationSuccess()
    }
    
    func captchaRequiredFailed(with message: String) {
        asyncOperationSuccess()
        view.showErrorTitle(withText: message)
    }
    
    func showSupportView() {
        view.showSupportView()
    }
    
    func showFAQView() {
        view.showFAQView()
    }

    func setupEtk(isShowEtk: Bool) {
        if isShowEtk {
            confirmEtk = false
        } else {
            confirmEtk = nil
        }
        view.setupEtk(isShowEtk: isShowEtk)
        updateNextButtonStatus()
    }

    func finishedLoadingTermsOfUse(eula: String) {
        eulaText = eula
    }

    func failedToLoadTermsOfUse(errorString: String) {
        view.showErrorTitle(withText: errorString)
    }
}

extension RegistrationPresenter: CaptchaViewErrorDelegate {
    
    func showCaptchaError(error: Error) {
        
        view.showErrorTitle(withText: error.description)
    }
}
