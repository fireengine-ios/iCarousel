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
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    var isFromLogin = false
    var isFromRegistration = false
    
    var eula: EULAResponse?
    
    var phoneNumber: String?
    
    var etkAuth: Bool? {
        didSet {
            /// if etkAuth changes, i have to update dataStorage because it will be passed to the next screen where this value will be needed
            dataStorage.signUpResponse.etkAuth = etkAuth
        }
    }
    
    var kvkkAuth: Bool? {
        didSet {
            dataStorage.signUpResponse.kvkkAuth = kvkkAuth
        }
    }
    
    var globalPermAuth: Bool? {
        didSet {
            dataStorage.signUpResponse.globalPermAuth = globalPermAuth
        }
    }
    
    func loadTermsAndUses() {
        
        DispatchQueue.toBackground { [weak self] in
            self?.eulaService.eulaGet { [weak self] response in
                switch response {
                case .success(let eulaContent):
                    self?.eula = eulaContent
                    self?.dataStorage.signUpResponse.eulaId = eulaContent.id
                    DispatchQueue.main.async {
                        self?.output.showLoadedTermsAndUses(eula: eulaContent.content ?? "")
                    }
                case .failed(let error):
                    DispatchQueue.toMain {
                        self?.output.failLoadTermsAndUses(errorString: error.localizedDescription)
                    }
                    assertionFailure("Failed move to Terms Description ")
                }
            }
        }
    }
    
    func applyEula() {
        guard let eulaID = eula?.id else {
            assertionFailure()
            return
        }
        
        eulaService.eulaApprove(
            eulaId: eulaID,
            etkAuth: etkAuth,
            kvkkAuth: kvkkAuth,
            globalPermAuth: globalPermAuth,
            success: { [weak self] successResponse in
                DispatchQueue.main.async {
                    self?.output.eulaApplied()
                }
            },
            fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.applyEulaFailed(errorResponse: errorResponse)
                }
        })
    }
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
        isFromRegistration = true
        dataStorage.signUpResponse.etkAuth = etkAuth
        dataStorage.signUpResponse.kvkkAuth = kvkkAuth
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.EulaScreen())
        analyticsService.logScreen(screen: .termsAndServices)
        analyticsService.trackDimentionsEveryClickGA(screen: .termsAndServices)
    }
    
    var signUpSuccessResponse: SignUpSuccessResponse {
        
        return dataStorage.signUpResponse
    }
    
    var userInfo: RegistrationUserInfoModel {
        
        return dataStorage.signUpUserInfo
    }
    
    var isLoggedIn: Bool {
        return tokenStorage.accessToken != nil
    }
    
    var cameFromLogin: Bool {
        return isFromLogin
    }
    
    var cameFromRegistration: Bool {
        return isFromRegistration
    }
}
