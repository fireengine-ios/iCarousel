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
    var isFromRegistration = false
    
    var eula: EULAResponse?
    
    var phoneNumber: String?
    
    var etkAuth: Bool? {
        didSet {
            /// if etkAuth changes, i have to update dataStorage because it will be passed to the next screen where this value will be needed
            let isEtkAuth = self.etkAuth == true
            dataStorage.signUpResponse.etkAuth = isEtkAuth
        }
    }
    
    var globalPermAuth: Bool? {
        didSet {
            let isGlobalPerm = self.globalPermAuth == true
            dataStorage.signUpResponse.globalPermAuth = isGlobalPerm
        }
    }
    
    func loadTermsAndUses() {
        
        DispatchQueue.toBackground { [weak self] in
            self?.eulaService.eulaGet { [weak self] response in
                switch response {
                case .success(let eulaContent):
                    self?.eula = eulaContent
                    self?.dataStorage.signUpResponse.eulaId = eulaContent.id
                    DispatchQueue.toMain {
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
        
        eulaService.eulaApprove(eulaId: eulaID, etkAuth: etkAuth, sucess: { [weak self] successResponce in
            DispatchQueue.main.async {
                self?.output.eulaApplied()
            }
            }, fail: { [weak self] errorResponce in
                DispatchQueue.main.async {
                    self?.output.applyEulaFaild(errorResponce: errorResponce)
                }
        })
    }
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
        isFromRegistration = true
        dataStorage.signUpResponse.etkAuth = etkAuth
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
    
    var cameFromRegistration: Bool {
        return isFromRegistration
    }
    
    func checkEtk() {
        /// phoneNumber will exist only for signup
        checkEtk(for: phoneNumber)
    }
    
    private func checkEtk(for phoneNumber: String?) {
        eulaService.getEtkAuth(for: phoneNumber) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                switch result {
                case .success(let isShowEtk):
                    self.output.setupEtk(isShowEtk: isShowEtk)
                    
                    /// if we show etk default value must be false (user didn't check etk)
                    if isShowEtk {
                        self.etkAuth = false
                    }
                case .failed(_):
                    self.output.setupEtk(isShowEtk: false)
                }
            }
        }
    }
    
    func checkGlobalPerm() {
        checkGlobalPerm(for: phoneNumber)
    }
    
    private func checkGlobalPerm(for phoneNumber: String?) {
        eulaService.getGlobalPermAuth(for: phoneNumber) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                switch result {
                case .success(let isShowGlobalPerm):
                    self.output.setupGlobalPerm(isShowGlobalPerm: isShowGlobalPerm)
                    
                    if isShowGlobalPerm {
                        self.globalPermAuth = false
                    }
                case .failed(_):
                    self.output.setupGlobalPerm(isShowGlobalPerm: false)
                }
            }
        }
    }
}
