//
//  SplashSplashInteractor.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Reachability
import WidgetKit

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
            if reachabilityService.isReachableViaWiFi || reachabilityService.isReachableViaWWAN {
                isTryingToLogin = false
            }
            failLogin()
            output.asyncOperationSuccess()
        } else {
            refreshAccessToken { [weak self] in
                /// self can be nil due logout
                SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                    self?.isTryingToLogin = false
                    SingletonStorage.shared.isJustRegistered = false
                    self?.successLogin()
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .success, loginType: .rememberMe))
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }, fail: { [weak self] error in
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .rememberMe))
                    /// we don't need logout here
                    /// only internet error
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
