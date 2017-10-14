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
    
    
    //MARK: - View output
    func viewIsReady() {
        //request info here
        interactor.prepareModels()
        interactor.requestGSMCountryCodes()
    }

    func nextButtonPressed() {
        view.collectInputedUserInfo()
    }
    
    func collectedUserInfo(email: String, code: String, phone: String, password: String, repassword: String) {
        interactor.validateUserInfo(email: email.replacingOccurrences(of: " ", with: ""), code: code, phone: phone, password: password, repassword: repassword)
    }
    
    func infoButtonGotPressed(with type: UserValidationResults) {
        showPopUp(forType: type)
    }
    //MARK: - Interactor output
    
    func prepearedModels(models: [BaseCellModel]) {
        view.setupInitialState(withModels: models)
    }
    
    func composedGSMCCodes(models:[GSMCodeModel]) {
        view.setupPicker(withModels: models)
    }
    
    func userValid(email: String, phone: String, passpword: String) {
        router.termsAndServices(with: view)
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
        compliteAsyncOperationEnableScreen(errorMessage: result)
    }
    
    func signUpSucces(withResult result: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        compliteAsyncOperationEnableScreen()
        router.phoneVerification(sigUpResponse: result, userInfo: userInfo)

    }
    
    func showPopUp(forType type: UserValidationResults) {
        switch type {
        case .mailNotValid:
            CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.invalidMailErrorText, okButtonText: TextConstants.ok)
        case .passwordNotValid:
            CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.invalidPasswordText, okButtonText: TextConstants.ok)
        case .phoneNotValid:
            CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.invalidPhoneNumberText, okButtonText: TextConstants.ok)
        case .passwodsNotMatch:
            CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.invalidPasswordMatchText, okButtonText: TextConstants.ok)
        default:
            break
        }
    }
    
    // MARK: BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
