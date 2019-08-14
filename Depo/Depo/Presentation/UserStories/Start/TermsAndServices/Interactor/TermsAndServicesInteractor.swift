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
            dataStorage.signUpResponse.etkAuth = etkAuth
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
        
        eulaService.eulaApprove(eulaId: eulaID, etkAuth: etkAuth, globalPermAuth: globalPermAuth, success: { [weak self] successResponse in
            DispatchQueue.main.async {
                self?.output.eulaApplied()
            }
            }, fail: { [weak self] errorResponse in
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
    
    func checkEtkAndGlobalPermissions() {
        var isShowEtk = true
        var isShowGlobalPerm = true
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        checkEtk(for: phoneNumber) { result in
            isShowEtk = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        checkGlobalPerm(for: phoneNumber) { result in
            isShowGlobalPerm = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.output.setupEtkAndGlobalPermissions(isShowEtk: isShowEtk, isShowGlobalPerm: isShowGlobalPerm)
        }
        
    }
    
    func checkEtk() {
        /// phoneNumber will exist only for signup
        checkEtk(for: phoneNumber) { [weak self] isShowEtk in
            self?.output.setupEtk(isShowEtk: isShowEtk)
        }
    }
    
    private func checkEtk(for phoneNumber: String?, completion: BoolHandler?) {
        eulaService.getEtkAuth(for: phoneNumber) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                switch result {
                case .success(let isShowEtk):
                    completion?(isShowEtk)
                    /// if we show etk default value must be false (user didn't check etk)
                    if isShowEtk {
                        self.etkAuth = false
                    }
                case .failed(_):
                    completion?(false)
                }
            }
        }
    }
    
    func checkGlobalPerm() {
        checkGlobalPerm(for: phoneNumber) { [weak self] isShowGlobalPerm in
            self?.output.setupGlobalPerm(isShowGlobalPerm: isShowGlobalPerm)
        }
    }
    
    private func checkGlobalPerm(for phoneNumber: String?, completion: @escaping BoolHandler) {
        eulaService.getGlobalPermAuth(for: phoneNumber) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                switch result {
                case .success(let isShowGlobalPerm):
                    completion(isShowGlobalPerm)
                    
                    if isShowGlobalPerm {
                        self.globalPermAuth = false
                    }
                case .failed(_):
                    completion(false)
                }
            }
        }
    }
}
