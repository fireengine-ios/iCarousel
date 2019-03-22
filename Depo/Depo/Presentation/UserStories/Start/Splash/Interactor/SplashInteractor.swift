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
        setupReachabilityIfNeed()
        
        if tokenStorage.accessToken == nil {
            if ReachabilityService().isReachableViaWiFi {
                isTryingToLogin = false
                analyticsService.trackLoginEvent(error: .serverError)
                failLogin()
            } else {
                authenticationService.turkcellAuth(success: { [weak self] in
                    AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
                    self?.tokenStorage.isRememberMe = true
//                    ItemsRepository.sharedSession.updateCache()
                    SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                        self?.isTryingToLogin = false
//                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
                        self?.turkcellSuccessLogin()
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
                    self?.isTryingToLogin = false
                    let loginError = LoginResponseError(with: response)
                    self?.analyticsService.trackLoginEvent(error: loginError)
                    self?.output.asyncOperationSuccess()
                    if response.isServerUnderMaintenance {
                        self?.output.onFailGetAccountInfo(error: response)
                    } else {
                        self?.failLogin()
                    }
                })
            }
        } else {
            SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                self?.isTryingToLogin = false
                self?.successLogin()
            }, fail: { [weak self] error in
                /// we don't need logout here
                /// only internet error
                //self?.failLogin()
                DispatchQueue.toMain {
                    self?.isTryingToLogin = false
                    if ReachabilityService().isReachable {
                        self?.output.onFailGetAccountInfo(error: error)
                    } else {
                        self?.output.onNetworkFail()
                    }
                }
            })
        }
    }
    
    func turkcellSuccessLogin() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
        DispatchQueue.toMain {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success, eventValue: GADementionValues.login.turkcellGSM.text)
//        ItemsRepository.sharedSession.updateCache()
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
        DispatchQueue.toMain {
            self.output.onSuccessLogin()
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
