//
//  TermsAndServicesTermsAndServicesInteractor.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesInteractor: TermsAndServicesInteractorInput {

    weak var output: TermsAndServicesInteractorOutput!
    private let eulaService = EulaService()
    
    private let dataStorage = TermsAndServicesDataStorage()
    private lazy var authenticationService = AuthenticationService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var isFromLogin = false
    
    var eula: Eula?
    
    func loadTermsAndUses() {
        eulaService.eulaGet(sucess: { [weak self] eula in
            guard let eulaR = eula as? Eula else {
                return
            }
            self?.eula = eulaR
            DispatchQueue.toMain {
                self?.output.showLoadedTermsAndUses(eula: eulaR.content ?? "")
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failLoadTermsAndUses(errorString: errorResponse.description)
                }
        })
    }
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .termsAndServices)
        analyticsService.trackDimentionsEveryClickGA(screen: .termsAndServices)
    }
    
    var signUpSuccessResponse: SignUpSuccessResponse {
    
        return dataStorage.signUpResponse
    }
    
    var userInfo: RegistrationUserInfoModel {
    
        return dataStorage.signUpUserInfo
    }
    
    var cameFromLogin: Bool {
        return isFromLogin
    }
    
    func signUpUser() {
        guard let sigUpInfo = SingletonStorage.shared.signUpInfo,
            let eulaId = eula?.id
            else { return }
        
        let signUpUser = SignUpUser(phone: sigUpInfo.phone,
                                    mail: sigUpInfo.mail,
                                    password: sigUpInfo.password,
                                    eulaId: eulaId,
                                    captchaID: sigUpInfo.captchaID,
                                    captchaAnswer: sigUpInfo.captchaAnswer)
        
        authenticationService.signUp(user: signUpUser, sucess: { [weak self] result in
            DispatchQueue.main.async {
                guard let t = result as? SignUpSuccessResponse else {
                    return
                }
                self?.dataStorage.signUpResponse = t
                self?.dataStorage.signUpUserInfo = SingletonStorage.shared.signUpInfo
                SingletonStorage.shared.referenceToken = t.referenceToken
                
                self?.analyticsService.track(event: .signUp)
                self?.analyticsService.trackSignupEvent()
                
                self?.output.signUpSuccessed()
            }
        }, fail: { [weak self] errorResponce in
            DispatchQueue.main.async {
                if case ErrorResponse.error(let error) = errorResponce,
                    let statusError = error as? ServerStatusError,
                    let signUpError = SignupResponseError(with: statusError) {
                    
                    self?.analyticsService.trackSignupEvent(error: signUpError)
                    
                    if signUpError == .captchaRequired || signUpError == .incorrectCaptcha {
                        self?.output.signupFailedCaptchaRequired()
                    }
                } else {
                    self?.analyticsService.trackSignupEvent(error: .serverError)
                }

                self?.output.signupFailed(errorResponce: errorResponce)
            }
        })
    }
    
    func applyEula() {
        guard let eula_ = eula, let eulaID = eula_.id else {
            return
        }
        
        eulaService.eulaApprove(eulaId: eulaID, sucess: { [weak self] successResponce in
            DispatchQueue.main.async {
                self?.output.eulaApplied()
            }
        }, fail: { [weak self] errorResponce in
            DispatchQueue.main.async {
                self?.output.applyEulaFaild(errorResponce: errorResponce)
            }
        })
    }
}
