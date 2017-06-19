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
            //TODO: also add let locale = Locale.current check, in case if there is no sim
            //if no location then use default. (Also check original code)
        }
    }
    
    func validateUserInfo(email: String, phone: String, password: String, repassword: String) {
        let validationService = UserValidator()
        let validationResult = validationService.validateUserInfo(mail: email, phone: phone, password: password, repassword: repassword)
        if validationResult == .allValid {
            self.output.userValid(email: email, phone: phone, passpword: password)
        } else {
            self.output.userInvalid(withResult: validationResult)
        }
    }
    
    func signUPUser(email: String, phone: String, password: String, repassword: String) {
            //send reques and parse it
        //tell presenter that everytging ok and we cann pass to the next screen
    }
    
    func showLoadingIndicator() {
        
    }
    
    func showCustomPopUp(withText text: String) {// Alert
        let customPopUp = CustomPopUp()
        customPopUp.showAlert(withText: NSLocalizedString(text, comment: ""))
    }
}
