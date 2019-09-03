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
            if retriesCount >= NumericConstants.showSupportViewAttempts {
                showSupportView()
            }
        }
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .signUpScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .signUpScreen)
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
        
        authenticationService.signUp(user: signUpUser, sucess: { [weak self] response in
            DispatchQueue.main.async {
                guard let result = response as? SignUpSuccessResponse else {
                    let error = CustomErrors.serverError("An error has occurred while register new user.")
                    let errorResponse = ErrorResponse.error(error)
                    self?.output.signUpFailed(errorResponse: errorResponse)
                    return
                }
                
                self?.retriesCount = 0
                
                SingletonStorage.shared.referenceToken = result.referenceToken
                
                self?.analyticsService.track(event: .signUp)
                self?.analyticsService.trackSignupEvent()
                
                SingletonStorage.shared.isJustRegistered = true
                self?.output.signUpSuccessed(signUpUserInfo: SingletonStorage.shared.signUpInfo, signUpResponse: result)
            }
            }, fail: { [weak self] errorResponse in
                self?.retriesCount += 1
                
                DispatchQueue.main.async { [weak self] in
                    switch errorResponse {
                    case .error(let error):
                        if let valueError = error as? ServerValueError,
                            let signUpError = SignupResponseError(with: valueError) {
                            
                            self?.analyticsService.trackSignupEvent(error: signUpError)
                            
                            ///only with this error type captcha required error is processing
                            if signUpError == .captchaRequired || signUpError == .incorrectCaptcha {
                                self?.captchaRequired = true
                                self?.output.captchaRequired(required: true)
                            }
                        } else if let statusError = error as? ServerStatusError,
                            let signUpError = SignupResponseError(with: statusError) {
                            
                            self?.analyticsService.trackSignupEvent(error: signUpError)
                        }
                        
                    default:
                        self?.analyticsService.trackSignupEvent(error: .serverError)
                        
                    }

                    self?.output.signUpFailed(errorResponse: errorResponse)
                }
        })
    }
    
    func showSupportView() {
        output.showSupportView()
    }
}
