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
    private lazy var captchaService = CaptchaService()
    
    func trackScreen() {
        analyticsService.logScreen(screen: .signUpScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .signUpScreen)
    }
    
    func prepareModels() {
        output.prepearedModels(models: dataStorage.getModels())
    }
    
    func requestGSMCountryCodes() {
        let gsmCompositor = CounrtiesGSMCodeCompositor()
        let models = gsmCompositor.getGSMCCModels()
        dataStorage.gsmModels = models
        output.composedGSMCCodes(models: models)
    }
    
    func validateUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?) {
       
        let validationResult = validationService.validateUserInfo(mail: email, code: code, phone: phone, password: password, repassword: repassword)
        if validationResult.count == 0 {//== .allValid {
            dataStorage.userRegistrationInfo = RegistrationUserInfoModel(mail: email, phone: code + phone, password: password, captchaID: captchaID, captchaAnswer: captchaAnswer)
            SingletonStorage.shared.signUpInfo = dataStorage.userRegistrationInfo
            output.userValid(email: email, phone: code + phone, passpword: password, captchaID: captchaID, captchaAnswer: captchaAnswer)
        } else {
            output.userInvalid(withResult: validationResult)
        }
    }
    
    func checkCaptchaRequerement() {
        CaptchaSignUpRequrementService().getCaptchaRequrement { [weak self] response in
            switch response {
            case .success(let boolResult):
                self?.output.captchaRequred(requred: boolResult)
            case .failed(_):
                self?.output.captchaRequredFailed()
            }
        }
        ///Implementation with old request bellow
//        captchaService.getSignUpCaptchaRequrement(sucess: { [weak self] succesResponse in
//            guard let succesResponse = succesResponse as? CaptchaSignUpRequrementResponse else {
//                self?.output.captchaRequredFailed()
//                return
//            }
//            self?.output.captchaRequred(requred: succesResponse.captchaRequred)
//
//        }) { [weak self] errorResponse in
//            self?.output.captchaRequredFailed()
//        }
    }
}
