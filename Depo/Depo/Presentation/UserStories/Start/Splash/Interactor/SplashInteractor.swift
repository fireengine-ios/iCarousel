//
//  SplashSplashInteractor.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Reachability

class SplashInteractor: SplashInteractorInput {

    weak var output: SplashInteractorOutput!
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var authenticationService = AuthenticationService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var reachabilityService = Reachability()
    private lazy var authorizationRepository: AuthorizationRepository = factory.resolve()
    
    private var isTryingToLogin = false
    private var isReachabilityStarted = false
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    deinit {
        reachabilityService?.stopNotifier()
    }
    
    private func setupReachabilityIfNeed() {
        if isReachabilityStarted {
            return
        }
        isReachabilityStarted = true
        
        guard let reachability = reachabilityService else {
            assertionFailure()
            return
        }
        
        reachability.whenReachable = { [weak self] reachability in
            self?.startLoginInBackground()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            assertionFailure("\(#function): can't start reachability notifier")
        }
    }
    
    func startLoginInBackground() {
        if isTryingToLogin {
            return
        }
        isTryingToLogin = true
        refreshAccessToken { [weak self] in
            /// self can be nil due logout
            self?.loginInBackground()
        }
    }
    
    private func refreshAccessToken(complition: @escaping VoidHandler) {
        if tokenStorage.refreshToken == nil {
            failLogin()
        }
        authorizationRepository.refreshTokens { _, accessToken, _  in
            if let accessToken = accessToken {
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.accessToken = accessToken
            }
            complition()
        }
    }
    
    private func loginInBackground() {
        setupReachabilityIfNeed()
        
        if tokenStorage.accessToken == nil {
            if ReachabilityService().isReachableViaWiFi {
                analyticsService.trackLoginEvent(error: .serverError)
                failLogin()
                isTryingToLogin = false
            } else {
                authenticationService.turkcellAuth(success: { [weak self] in
                    AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
                    self?.tokenStorage.isRememberMe = true
                    SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                        self?.turkcellSuccessLogin()
                        self?.isTryingToLogin = false
                    }, fail: { [weak self] error in
                        self?.isTryingToLogin = false
                        let loginError = LoginResponseError(with: error)
                        self?.analyticsService.trackLoginEvent(error: loginError)
                        self?.output.asyncOperationSuccess()
                        if error.isServerUnderMaintenance {
                            self?.output.onFailGetAccountInfo(error: error)
                        } else {
                            self?.failLogin()
                        }
                    })
                }, fail: { [weak self] response in
                    let loginError = LoginResponseError(with: response)
                    self?.analyticsService.trackLoginEvent(error: loginError)
                    self?.output.asyncOperationSuccess()
                    if response.isServerUnderMaintenance {
                        self?.output.onFailGetAccountInfo(error: response)
                    } else {
                        self?.failLogin()
                    }
                    self?.isTryingToLogin = false
                })
            }
        } else {
            SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                self?.successLogin()
            }, fail: { [weak self] error in
                /// we don't need logout here
                /// only internet error
                //self?.failLogin()
                DispatchQueue.toMain {
                    if ReachabilityService().isReachable {
                        self?.output.onFailGetAccountInfo(error: error)
                    } else {
                        self?.output.onNetworkFail()
                    }
                    self?.isTryingToLogin = false
                }
            })
        }
    }
    
    func turkcellSuccessLogin() {

        analyticsService.trackLoginEvent(loginType: GADementionValues.login.turkcellGSM)
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)

        DispatchQueue.toMain {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin() {
        analyticsService.trackLoginEvent(loginType: GADementionValues.login.rememberLogin)
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)
        DispatchQueue.toMain {
            self.output.onSuccessLogin()
            self.isTryingToLogin = false
        }
    }
    
    func failLogin() {
        DispatchQueue.toMain {
            self.output.onFailLogin()
            if !ReachabilityService().isReachable {
                self.output.onNetworkFail()
            }
        }
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] successResponce in
            DispatchQueue.toMain {
                self?.output.onSuccessEULA()
            }
        }) { [weak self] errorResponce in
            DispatchQueue.toMain {
                if case ErrorResponse.error(let error) = errorResponce, error.isNetworkError {
                    UIApplication.showErrorAlert(message: errorResponce.description)
                } else {
                    self?.output.onFailEULA()
                }
            }
        }
    }
    
    func checkEmptyEmail() {
        authenticationService.checkEmptyEmail { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let show):
                    self?.output.showEmptyEmail(show: show)
                case .failed(let error):
                    print(error.description)
                }
            }
        }
    }
    
    func clearAllPreviouslyStoredInfo() {
        CoreDataStack.default.clearDataBase()
    }
    
    func updateUserLanguage() {
        authenticationService.updateUserLanguage(Device.supportedLocale) { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(_):
                    self?.output.updateUserLanguageSuccess()
                case .failed(let error):
                    self?.output.updateUserLanguageFailed(error: error)
                }
            }
        }
    }
}
