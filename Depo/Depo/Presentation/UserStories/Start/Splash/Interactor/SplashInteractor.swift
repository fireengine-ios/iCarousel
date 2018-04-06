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
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }

    func startLoginInBackroung() {
        if tokenStorage.accessToken == nil {
            if ReachabilityService().isReachableViaWiFi {
                failLogin()
            } else {
                authenticationService.turkcellAuth(success: { [weak self] in
                    self?.turkcellSuccessLogin()
                }, fail: { [weak self] response in
                    self?.output.asyncOperationSucces()
                    self?.output.onFailLogin()
                })
            }
        } else {
            successLogin()
        }
    }
    
    func turkcellSuccessLogin() {
        DispatchQueue.main.async {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin() {
        DispatchQueue.main.async {
            self.output.onSuccessLogin()
        }
    }
    
    func failLogin() {
        DispatchQueue.main.async {
            self.output.onFailLogin()
            if !ReachabilityService().isReachable {
                self.output.onNetworkFail()
            }
        }
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] successResponce in
            DispatchQueue.main.async {
                self?.output.onSuccessEULA()
            }
        }) { [weak self] errorResponce in
            DispatchQueue.main.async {
                if case ErrorResponse.error(let error) = errorResponce, error is URLError {
                    UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
                } else {
                    self?.output.onFailEULA()
                }
            }
        }
    }
    
    func checkEmptyEmail() {
        authService.checkEmptyEmail { [weak self] result in
            DispatchQueue.main.async {
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
            DispatchQueue.main.async {
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
