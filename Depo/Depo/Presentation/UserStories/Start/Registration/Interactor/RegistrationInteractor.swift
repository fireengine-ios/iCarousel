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
    private lazy var eulaService = EulaService()

    var captchaRequired = false
    private var retriesCount = 0 {
        didSet {
            showRelatedHelperView()
        }
    }

    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SignupScreen())
        analyticsService.logScreen(screen: .signUpScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .signUpScreen)
    }
    
    func trackSupportSubjectEvent(type: SupportFormSubjectTypeProtocol) {
        analyticsService.trackSupportEvent(screenType: .signup, subject: type, isSupportForm: false)
    }

    func checkEtkAndGlobalPermissions(code: String, phone: String) {
        // We're only checking for ETK, global permission is ignored for now.
        if code == "+90" && phone.count == 10 {
            checkEtk(for: code + phone) { result in
                self.output.setupEtk(isShowEtk: result)
            }
        } else {
            self.output.setupEtk(isShowEtk: false)
        }
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
        CaptchaSignUpRequrementService().getCaptchaRequrement(isSignUp: true) { [weak self] response in
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

    func loadTermsOfUse() {
        eulaService.eulaGet { [weak self] response in
            switch response {
            case .success(let eulaContent):
                self?.output.finishedLoadingTermsOfUse(eula: eulaContent.content ?? "")
            case .failed(let error):
                self?.output.failedToLoadTermsOfUse(errorString: error.localizedDescription)
                assertionFailure("Failed move to Terms Description ")
            }
        }
    }
    
    func signUpUser(_ userInfo: RegistrationUserInfoModel) {
        
        ///sentOtp = false as a task requirements (FE-1055)
        let signUpUser = SignUpUser(registrationUserInfo: userInfo, sentOtp: false)
        
        authenticationService.signUp(user: signUpUser) { [weak self] response in
            guard let self = self else {
                return
            }
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.SignUp(status: .success))
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
                
                if let signUpError = error as? SignupResponseError {

                    self.analyticsService.trackSignupEvent(error: signUpError)
                    
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.SignUp(status: .failure, errorType: signUpError.dimensionValue))
                    
                    ///only with this error type captcha required error is processing
                    if signUpError.isCaptchaError {
                        self.captchaRequired = true
                        self.output.captchaRequired(required: true)
                    }
                } else {
                    self.analyticsService.trackCustomGAEvent(eventCategory: .errors,
                                                             eventActions: .serviceError,
                                                             eventLabel: .serverError,
                                                             eventValue: error.description)
                }
                
                self.output.signUpFailed(errorResponse: error)
            }
        }
    }
    
    func showSupportView() {
        output.showSupportView()
    }
    
    private func showRelatedHelperView() {
        if retriesCount == NumericConstants.showFAQViewAttempts {
            output?.showFAQView()
        } else {
            #if LIFEBOX
            FirebaseRemoteConfig.shared.fetchAttemptsBeforeSupportOnSignup() { [weak self] attempts in
                guard let self = self else {
                    return
                }
                
                if self.retriesCount >= attempts {
                    DispatchQueue.main.async {
                        self.output?.showSupportView()
                    }
                }
            }
            #else
            if retriesCount >= NumericConstants.showSupportViewAttempts {
                output?.showSupportView()
            }
            #endif
        }
    }

    private func checkEtk(for phoneNumber: String?, completion: BoolHandler?) {
        eulaService.getEtkAuth(for: phoneNumber) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isShowEtk):
                    completion?(isShowEtk)
                case .failed(_):
                    completion?(false)
                }
            }
        }
    }
}
