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
            case .failed(let error):
                if error.isServerUnderMaintenance {
                    self?.output.captchaRequredFailed(with: error.description)
                } else {
                    self?.output.captchaRequredFailed()
                }
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
    
    func signUpUser(email: String, phone: String, passpword: String, captchaID: String?, captchaAnswer: String?) {
        
        let signUpUser = SignUpUser(phone: phone,
                                    mail: email,
                                    password: passpword,
                                    sendOtp: false,
                                    captchaID: captchaID,
                                    captchaAnswer: captchaAnswer)
        
        authenticationService.signUp(user: signUpUser, sucess: { [weak self] response in
                DispatchQueue.main.async {
                    guard let result = response as? SignUpSuccessResponse else {
                        let error = CustomErrors.serverError("An error has occurred while register new user")
                        let errorResponse = ErrorResponse.error(error)
                        self?.output.signUpFailed(errorResponce: errorResponse)
                        return
                    }

                    SingletonStorage.shared.referenceToken = result.referenceToken
                    
                    self?.analyticsService.track(event: .signUp)
                    self?.analyticsService.trackSignupEvent()
                    
                    self?.output.signUpSuccessed(signUpUserInfo: SingletonStorage.shared.signUpInfo, signUpResponse: result)
                }
            }, fail: { [weak self] errorResponce in
                DispatchQueue.main.async { [weak self] in
                    switch errorResponce {
                    case .error(let error):
                        if let statusError = error as? ServerStatusError,
                           let signUpError = SignupResponseError(with: statusError) {
                            
                            self?.analyticsService.trackSignupEvent(error: signUpError)
                            
                            if signUpError == .captchaRequired || signUpError == .incorrectCaptcha {
                                self?.output.captchaRequred(requred: true)
                            }
                        }
                    default:
                        self?.analyticsService.trackSignupEvent(error: .serverError)
                    }

                    self?.output.signUpFailed(errorResponce: errorResponce)
                }
        })
    }
}
