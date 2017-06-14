//
//  RegistrationRegistrationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RegistrationInteractor: RegistrationInteractorInput {

    weak var output: RegistrationInteractorOutput!
    let dataStorage = DataStorage()
    
    func requestTitle() {
        self.output.pass(title: "butter", forRowIndex: 0)
    }
    
    func prepareModels() {
        //PREPERes models here and call output
        self.output.prepearedModels(models: dataStorage.getModels())
    }
    
    func requestGSMCountryCodes() {
        let gsmCompositor = CounrtiesGSMCodeCompositor()
        let models = gsmCompositor.getGSMCCModels()
        self.dataStorage.gsmModels.removeAll()
        self.dataStorage.gsmModels.append(contentsOf: models)
        self.output.composedGSMCCodes(models:models)
    }
    
    func signUPUser(email: String, phone: String, passport: String, repassword: String) {
        //validate
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        let validationService = UserValidator()
        if validationService.isUserInfoValid(mail: email, phone: phone, password: passport, repassword: repassword) {
            
        }
        //send reques and parse it
        //tell presenter that everytging ok and we cann pass to the next screen
    }
    
}
