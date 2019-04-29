//
//  RegistrationRegistrationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import UIKit

class RegistrationPresenter: BasePresenter, RegistrationModuleInput, RegistrationViewOutput, RegistrationInteractorOutput {
    
    weak var view: RegistrationViewInput!
    var interactor: RegistrationInteractorInput!
    var router: RegistrationRouterInput!
    
    
    // MARK: - View output
    func viewIsReady() {
        interactor.trackScreen()
        startAsyncOperation()
        interactor.checkCaptchaRequerement()
        interactor.prepareModels()
        interactor.requestGSMCountryCodes()
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
    
    func infoButtonGotPressed(with type: UserValidationResults) {
        showPopUp(forType: type)
    }
    // MARK: - Interactor output
    
    func prepearedModels(models: [BaseCellModel]) {
        view.setupInitialState(withModels: models)
    }
    
    func composedGSMCCodes(models: [GSMCodeModel]) {
        view.setupPicker(withModels: models)
    }
    
    func userValid(email: String, phone: String, passpword: String, captchaID: String?, captchaAnswer: String?) {
        router.termsAndServices(with: view, email: email, phoneNumber: phone)
    }
    
    func userInvalid(withResult result: [UserValidationResults]) {
        var prioratizedErrorTitle = ""
        for errorType in result {
            switch errorType {
            case .mailIsEmpty, .passwordIsEmpty, .phoneIsEmpty, .repasswordIsEmpty:
                view.showInfoButton(forType: errorType)
            case .mailNotValid:
                prioratizedErrorTitle = TextConstants.registrationMailError
            case .passwordNotValid:
                if prioratizedErrorTitle == "" {
                    prioratizedErrorTitle = TextConstants.registrationPasswordError
                }
            case .passwodsNotMatch:
                if prioratizedErrorTitle == "" {
                    prioratizedErrorTitle = TextConstants.registrationPasswordNotMatchError
                }
            default:
                break
            }
        }
        if prioratizedErrorTitle != "" {
             view.showErrorTitle(withText: prioratizedErrorTitle)
        }
//        result.forEach {view.showInfoButton(forType:$0)
//        }
    }
    
    func signUpFailed(withResult result: String?) {
        completeAsyncOperationEnableScreen(errorMessage: result)
    }
    
    func signUpSucces(withResult result: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        completeAsyncOperationEnableScreen()
        router.phoneVerification(sigUpResponse: result, userInfo: userInfo)

    }
    
    func showPopUp(forType type: UserValidationResults) {
        let text: String
        switch type {
        case .mailNotValid:
            text = TextConstants.invalidMailErrorText
        case .passwordNotValid:
            text = TextConstants.invalidPasswordText
        case .phoneNotValid:
            text = TextConstants.invalidPhoneNumberText
        case .passwodsNotMatch:
            text = TextConstants.invalidPasswordMatchText
        default:
            return
        }
        UIApplication.showErrorAlert(message: text)
    }
    
    func captchaRequred(requred: Bool) {
        if requred, let captchaVC = router.getCapcha() {
            view.setupCaptchaVC(captchaVC: captchaVC)
        }
        asyncOperationSuccess()
    }
    
    func captchaRequredFailed() {
        asyncOperationSuccess()
    }
    
    func captchaRequredFailed(with message: String) {
        asyncOperationSuccess()
        view.showErrorTitle(withText: message)
    }
    
    // MARK: BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
