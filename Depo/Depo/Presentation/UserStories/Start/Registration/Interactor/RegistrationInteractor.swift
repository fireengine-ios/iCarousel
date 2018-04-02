//
//  RegistrationRegistrationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RegistrationInteractor: RegistrationInteractorInput {
    
    weak var output: RegistrationInteractorOutput!
    private let dataStorage = DataStorage()
    private lazy var validationService = UserValidator()
    private lazy var authenticationService = AuthenticationService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func prepareModels() {
        output.prepearedModels(models: dataStorage.getModels())
    }
    
    func requestGSMCountryCodes() {
        let gsmCompositor = CounrtiesGSMCodeCompositor()
        let models = gsmCompositor.getGSMCCModels()
        dataStorage.gsmModels = models
        output.composedGSMCCodes(models: models)
    }
    
    func validateUserInfo(email: String, code: String, phone: String, password: String, repassword: String) {
       
        let validationResult = validationService.validateUserInfo(mail: email, code: code, phone: phone, password: password, repassword: repassword)
        if validationResult.count == 0 {//== .allValid {
            dataStorage.userRegistrationInfo = RegistrationUserInfoModel(mail: email, phone: code + phone, password: password)
            SingletonStorage.shared.signUpInfo = dataStorage.userRegistrationInfo
            output.userValid(email: email, phone: code + phone, passpword: password)
        } else {
            output.userInvalid(withResult: validationResult)
        }
    }
    
    func signUPUser(email: String, phone: String, password: String) {
        let sigUpUser = SignUpUser(phone: phone,
                                   mail: email,
                                   password: password,
                                   eulaId: 0) /// 0 is server logic
        
        authenticationService.signUp(user: sigUpUser, sucess: { [weak self] result in
            DispatchQueue.main.async {
                guard let t = result as? SignUpSuccessResponse,
                    let userRegistrationInfo = self?.dataStorage.userRegistrationInfo  else {
                        return
                }
                self?.analyticsService.track(event: .signUp)
                self?.output.signUpSucces(withResult: t, userInfo: userRegistrationInfo)
            }
            }, fail: { [weak self] result in
                DispatchQueue.main.async {
                    self?.output.signUpFailed(withResult: result.description)
                }
        })
    }
}
