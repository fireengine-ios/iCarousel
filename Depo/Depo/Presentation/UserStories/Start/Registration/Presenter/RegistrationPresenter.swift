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
    func userValid(_ userInfo: RegistrationUserInfoModel) {
        guard confirmAgreements else {
            view?.showErrorTitle(withText: TextConstants.termsAndUseCheckboxErrorText)
            return
        }

        startAsyncOperationDisableScreen()
        interactor.signUpAndApplyEula(userInfo, etkAuth: confirmEtk, globalPermAuth: confirmGlobalPerm)
    }
    
    func userInvalid(withResult result: [UserValidationResults]) {
        ///sort is needed to priorities the error(empty field is high priority error)
        let sortedResult = result.sorted { _, rignt in
            let mailIsEmpty = (rignt == .mailIsEmpty )
            let phoneIsEmpty = (rignt == .phoneIsEmpty )
            let passwordIsEmpty = (rignt == .passwordIsEmpty )
            let repasswordIsEmpty = (rignt == .passwordIsEmpty )
            let isNeedSwitch = mailIsEmpty || phoneIsEmpty || passwordIsEmpty || repasswordIsEmpty
            return isNeedSwitch
        }
        
        sortedResult.forEach { errorType in
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
    
    func signUpSuccessed(signUpUserInfo: RegistrationUserInfoModel?, signUpResponse: SignUpSuccessResponse?) {
        guard let response = signUpResponse, let info = signUpUserInfo else {
            assertionFailure()
            return
        }

        completeAsyncOperationEnableScreen()
        router.phoneVerification(sigUpResponse: response, userInfo: info)
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
