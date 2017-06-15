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

    func viewIsReady() {
        //request info here
    }
    
    func prepareCells() {
        self.interactor.prepareModels()
        self.interactor.requestGSMCountryCodes()
    }
    
    func userInputed(forRow:Int, withValue: String) {
        // VALIDATE INFO FIRST then call validation results
    }
    
    func prepearedModels(models: [BaseCellModel]) {
        self.view.setupInitialState(withModels: models)
    }
    
    func setupModels(models: [BaseCellModel]) {
        
    }
    
    func pass(title: String, forRowIndex: Int) {
        debugPrint("titile is ", title)
    }
    
    func nextButtonPressed(withNavController navController: UINavigationController, email: String, phone: String, password: String, repassword: String) {
        self.interactor.signUPUser(email: email, phone: phone, passport: password, repassword: repassword)
        
//self.router.routNextVC(wihtNavigationController: navController)
    }
    
    func validatedUserInfo(withResult result: String) {
        self.view.prepareNavController()
    }
    
    func readyForPassing(withNavController navController: UINavigationController) {
        self.router.routNextVC(wihtNavigationController: navController)
    }
    
    func validatedUserInfo(withResult result: Bool) {
        
    }
    
    func composedGSMCCodes(models:[GSMCodeModel]) {
        self.view.setupPicker(withModels: models)
    }
}
