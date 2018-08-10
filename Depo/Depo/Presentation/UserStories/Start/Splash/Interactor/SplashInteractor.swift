//
//  SplashSplashInteractor.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SplashInteractor: SplashInteractorInput {

    weak var output: SplashInteractorOutput!
    
    let authService = AuthenticationService()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var authenticationService = AuthenticationService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }

    func startLoginInBackroung() {
        if tokenStorage.accessToken == nil {
            if ReachabilityService().isReachableViaWiFi {
                analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .falseLogin)
                failLogin()
            } else {
                authenticationService.turkcellAuth(success: { [weak self] in
                    self?.tokenStorage.isRememberMe = true
                    SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] _ in
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .trueLogin)
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
                        self?.turkcellSuccessLogin()
                    }, fail: { [weak self] error in
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .falseLogin)
                        self?.output.asyncOperationSucces()
                        self?.output.onFailLogin()
                    })
                }, fail: { [weak self] response in
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .falseLogin)
                    self?.output.asyncOperationSucces()
                    self?.output.onFailLogin()
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
                    if !ReachabilityService().isReachable {
                        self?.output.onNetworkFail()
                    }
                }
            })
        }
    }
    
    func turkcellSuccessLogin() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .trueLogin)
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
        DispatchQueue.toMain {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .trueLogin)
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
        DispatchQueue.toMain {
            self.output.onSuccessLogin()
        }
    }
    
    func failLogin() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .falseLogin)
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
        authService.checkEmptyEmail { [weak self] result in
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
        authService.updateUserLanguage(Device.supportedLocale) { [weak self] result in
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
