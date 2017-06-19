//
//  RegistrationRegistrationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import UIKit

class RegistrationPresenter: RegistrationModuleInput, RegistrationViewOutput, RegistrationInteractorOutput {

    weak var view: RegistrationViewInput!
    var interactor: RegistrationInteractorInput!
    var router: RegistrationRouterInput!
    
    //MARK: - View output
    func viewIsReady() {
        //request info here
        self.interactor.prepareModels()
        self.interactor.requestGSMCountryCodes()
        self.interactor.acquireCurrentGSMCode()
    }

    func nextButtonPressed() {
        self.view.collectInputedUserInfo()
    }
    
    func collectedUserInfo(email: String, phone: String, password: String, repassword: String) {
        self.interactor.validateUserInfo(email: email, phone: phone, password: password, repassword: repassword)
    }
    
    func readyForPassing(withNavController navController: UINavigationController) {
        self.router.routNextVC(wihtNavigationController: navController)
    }
    
    //MARK: - Interactor output
    
    func prepearedModels(models: [BaseCellModel]) {
        self.view.setupInitialState(withModels: models)
    }
    
    func composedGSMCCodes(models:[GSMCodeModel]) {
        self.view.setupPicker(withModels: models)
    }
    
    func userValid(email: String, phone: String, passpword: String) {
        
        /* TODO: Uncomment in the future, for now go straigt to phone vereficztion
        self.interactor.signUPUser(email: email, phone: phone, password: passpword, repassword: passpword)
        */
        self.router.routNextVC()
    }
    
    func userInvalid(withResult result: UserValidationResults) {
        switch result {
        case .mailNotValid:
            self.interactor.showCustomPopUp(withText: "EmailFormatErrorMessage")
        case .passwordNotValid:
            self.interactor.showCustomPopUp(withText: "PassFormatErrorMessage")
        case .phoneNotValid:
            self.interactor.showCustomPopUp(withText: "MsisdnFormatErrorMessage")
        case .passwodsNotMatch:
            self.interactor.showCustomPopUp(withText: "PassMismatchErrorMessage")
        default:
            break//no other types for now
//            self.interactor.showCustomPopUp(withText: <#T##String#>)
        }  
    }

    func signUpBeingProcessed() {
        self.interactor.showLoadingIndicator()
    }
    
    func signUpResult(withResult result: String) {
        
    }
}
