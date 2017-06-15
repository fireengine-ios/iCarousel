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
    
    func prepareModels() {
        //PREPEaRe models here and call output
        self.output.prepearedModels(models: dataStorage.getModels())
    }
    
    func requestGSMCountryCodes() {
        let gsmCompositor = CounrtiesGSMCodeCompositor()
        let models = gsmCompositor.getGSMCCModels()
        self.dataStorage.gsmModels.removeAll()
        self.dataStorage.gsmModels.append(contentsOf: models)
        self.output.composedGSMCCodes(models:models)
    }
    
    func acquireCurrentGSMCode() {
        if SimCardInfo.isSimDetected() {
            debugPrint("sim card present")
        }
    }
    
    func signUPUser(email: String, phone: String, passport: String, repassword: String) {
//        guard let appDelegate = UIApplication.shared.delegate else {
//            return
//        }
        let validationService = UserValidator()
        if validationService.isUserInfoValid(mail: email, phone: phone, password: passport, repassword: repassword) {
            //send reques and parse it
            
            //test----
            self.output.validatedUserInfo(withResult: "")
            //----test
        }
        
        //tell presenter that everytging ok and we cann pass to the next screen
    }
    
}
