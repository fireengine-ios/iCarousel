//
//  RegistrationRegistrationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RegistrationInteractor: RegistrationInteractorInput {
    
    weak var output: RegistrationInteractorOutput!
    private lazy var validationService = UserValidator()
    private lazy var authenticationService = AuthenticationService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var captchaService = CaptchaService()
    
    var captchaRequired = false
    private var retriesCount = 0 {
        didSet {
            if retriesCount == NumericConstants.showFAQViewAttempts {
                output?.showFAQView()
            } else if retriesCount >= NumericConstants.showSupportViewAttempts {
                output?.showSupportView()
            }
        }
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .signUpScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .signUpScreen)
    }
    
    func trackSupportSubjectEvent(type: SupportFormSubjectTypeProtocol) {
        analyticsService.trackSupportEvent(screenType: .signup, subject: type, isSupportForm: false)
    }
    
    func validateUserInfo(email: String, code: String, phone: String, password: String, repassword: String, captchaID: String?, captchaAnswer: String?) {
        
        let validationResult: [UserValidationResults]
        validationResult = validationService.validateUserInfo(mail: email,
                                                              code: code,
                                                              phone: phone,
                                                              password: password,
                                                              repassword: repassword,
                                                              captchaAnswer: captchaRequired ? captchaAnswer : nil)
        
        if validationResult.count == 0 {//== .allValid {
            
            let signUpInfo: RegistrationUserInfoModel
            signUpInfo = RegistrationUserInfoModel(mail: email,
                                                   phone: code + phone,
                                                   password: password,
                                                   captchaID: captchaRequired ? captchaID : nil,
                                                   captchaAnswer: captchaRequired ? captchaAnswer : nil)
            
            SingletonStorage.shared.signUpInfo = signUpInfo
            
            output.userValid(signUpInfo)
        } else {
            retriesCount += 1
            
            output.userInvalid(withResult: validationResult)
        }
    }
    
    func checkCaptchaRequerement() {
        CaptchaSignUpRequrementService().getCaptchaRequrement { [weak self] response in
            switch response {
            case .success(let boolResult):
                self?.captchaRequired = boolResult
                self?.output.captchaRequired(required: boolResult)
            case .failed(let error):
                if error.isServerUnderMaintenance {
                    self?.output.captchaRequiredFailed(with: error.description)
                } else {
                    self?.output.captchaRequiredFailed()
                }
            }
        }
        ///Implementation with old request bellow
//        captchaService.getSignUpCaptchaRequrement(sucess: { [weak self] succesResponse in
//            guard let succesResponse = succesResponse as? CaptchaSignUpRequirementResponse else {
//                self?.output.captchaRequiredFailed()
//                return
//            }
//            self?.output.captchaRequired(required: succesResponse.captchaRequired)
//
//        }) { [weak self] errorResponse in
//            self?.output.captchaRequiredFailed()
//        }
    }
    
    func signUpUser(_ userInfo: RegistrationUserInfoModel) {
        
        ///sentOtp = false as a task requirements (FE-1055)
        let signUpUser = SignUpUser(registrationUserInfo: userInfo, sentOtp: false)
        
        authenticationService.signUp(user: signUpUser) { [weak self] response in
            guard let self = self else {
                return
            }
            
            switch response {
            case .success(let result):
                self.retriesCount = 0
                
                SingletonStorage.shared.referenceToken = result.referenceToken
                
                self.analyticsService.track(event: .signUp)
                self.analyticsService.trackSignupEvent()
                
                SingletonStorage.shared.isJustRegistered = true
                self.output.signUpSuccessed(signUpUserInfo: SingletonStorage.shared.signUpInfo, signUpResponse: result)
                
            case .failure(let error):
                self.retriesCount += 1
                
                self.analyticsService.trackSignupEvent(error: error)
                
                ///only with this error type captcha required error is processing
                if error.isCaptchaError {
                    self.captchaRequired = true
                    self.output.captchaRequired(required: true)
                }

                self.output.signUpFailed(errorResponse: error)
            }
        }
    }
    
    func showSupportView() {
        output.showSupportView()
    }
}
