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
    private lazy var reachabilityService = ReachabilityService.shared
    private lazy var authorizationRepository: AuthorizationRepository = factory.resolve()
    
    private var isTryingToLogin = false
    private var isReachabilityStarted = false
    private var isFirstLogin = false
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    deinit {
        reachabilityService.delegates.remove(self)
    }
    
    private func setupReachabilityIfNeed() {
        if isReachabilityStarted {
            return
        }
        isReachabilityStarted = true
        
        reachabilityService.delegates.add(self)
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SplashPageScreen())
    }
    
    func startLoginInBackground() {
        if isTryingToLogin {
            return
        }
        isTryingToLogin = true
        loginInBackground()
    }
    
    /// refresh access token on app start
    private func refreshAccessToken(complition: @escaping VoidHandler) {
        if tokenStorage.refreshToken == nil {
            failLogin()
        }
        authorizationRepository.refreshTokens { _, accessToken, _  in
            // TODO: create new func refreshTokens to save and return token
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
            if reachabilityService.isReachableViaWiFi {
                isTryingToLogin = false
                failLogin()
//                isTryingToLogin = false
            ///Additional check "if this is LTE",
            ///because our check for wifife or LTE looks like this:
                ///"self.reachability?.connection == .cellular && apiReachability.connection == .reachable"
            ///There is possability that we fall through to else, only because of no longer reachable internet.
            ///So we check second time.
            } else if reachabilityService.isReachableViaWWAN {
                authenticationService.turkcellAuth(success: { [weak self] in
                    AccountService().updateBrandType()
                    
                    AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
                    self?.tokenStorage.isRememberMe = true
                    
                    SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                        
                        SingletonStorage.shared.isJustRegistered = false
                        self?.isFirstLogin = true
                        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .success, loginType: .turkcell))
                        self?.turkcellSuccessLogin()
                        self?.isTryingToLogin = false
                    }, fail: { [weak self] error in
                        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .turkcell))
                        self?.isTryingToLogin = false
                        let loginError = LoginResponseError(with: error)
                        self?.analyticsService.trackLoginEvent(loginType: .turkcellGSM, error: loginError)
                        self?.output.asyncOperationSuccess()
                        if error.isServerUnderMaintenance {
                            self?.output.onFailGetAccountInfo(error: error)
                        } else {
                            self?.failLogin()
                        }
                    })
                }, fail: { [weak self] response in
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .turkcell))
                    let loginError = LoginResponseError(with: response)
                    self?.analyticsService.trackLoginEvent(loginType: .turkcellGSM, error: loginError)
                    self?.output.asyncOperationSuccess()
                    if response.isServerUnderMaintenance {
                        self?.output.onFailGetAccountInfo(error: response)
                    } else {
                        self?.failLogin()
                    }
                    self?.isTryingToLogin = false
                })
            } else {
                output.asyncOperationSuccess()
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .rememberMe))
                analyticsService.trackLoginEvent(loginType: .rememberLogin, error: .networkError)
                failLogin()
            }
        } else {
            refreshAccessToken { [weak self] in
                /// self can be nil due logout
                SingletonStorage.shared.getAccountInfoForUser(success: { _ in
                    CacheManager.shared.actualizeCache()
                    self?.isTryingToLogin = false
                    SingletonStorage.shared.isJustRegistered = false
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .success, loginType: .rememberMe))
                    self?.successLogin()
                }, fail: { [weak self] error in
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .rememberMe))
                    /// we don't need logout here
                    /// only internet error
                    //self?.failLogin()
                    DispatchQueue.toMain {
                        if self?.reachabilityService.isReachable == true {
                            self?.output.onFailGetAccountInfo(error: error)
                        } else {
                            self?.output.onNetworkFail()
                        }
                        self?.isTryingToLogin = false
                    }
                })
            }
        }
    }
    
    func turkcellSuccessLogin() {

        analyticsService.trackLoginEvent(loginType: .turkcellGSM)
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)

        DispatchQueue.toMain {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin() {
        analyticsService.trackLoginEvent(loginType: .rememberLogin)
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)
        DispatchQueue.toMain {
            self.output.onSuccessLogin()
            self.isTryingToLogin = false
        }
    }
    
    func failLogin() {
        DispatchQueue.toMain {
            self.output.onFailLogin()
            if !self.reachabilityService.isReachable {
                self.output.onNetworkFail()
            }
        }
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] successResponse in
            DispatchQueue.toMain {
                self?.output.onSuccessEULA()
            }
        }) { [weak self] errorResponse in
            DispatchQueue.toMain {
                if case ErrorResponse.error(let error) = errorResponse, error.isNetworkError {
                    UIApplication.showErrorAlert(message: errorResponse.description)
                } else {
                    self?.output.onFailEULA(isFirstLogin: self?.isFirstLogin == true)
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

//MARK: - ReachabilityServiceDelegate
extension SplashInteractor: ReachabilityServiceDelegate {
    func reachabilityDidChanged(_ service: ReachabilityService) {
        if service.isReachable {
            startLoginInBackground()
        }
    }
}
