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

    func startLoginInBackroung(){
        if tokenStorage.accessToken == nil {
            if ReachabilityService().isReachableViaWiFi {
                failLogin()
            } else {
                /// turkcell login
                authenticationService.turkcellAuth(success: { [weak self] in
                    self?.turkcellSuccessLogin()
                    //self?.successLogin()
                }, fail: { [weak self] response in
                    self?.output.asyncOperationSucces()
                    self?.output.onFailLogin()
                })
            }
        } else {
            successLogin()
        }
    }
    
    func turkcellSuccessLogin(){
        DispatchQueue.main.async {
            self.output.onSuccessLoginTurkcell()
        }
    }
    
    func successLogin(){
        DispatchQueue.main.async {
            self.output.onSuccessLogin()
        }
    }
    
    func failLogin(){
        DispatchQueue.main.async {
            self.output.onFailLogin()
            if !ReachabilityService().isReachable {
                self.output.onNetworkFail()
            }
        }
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] (successResponce) in
            DispatchQueue.main.async {
                self?.output.onSuccessEULA()
            }
        }) { [weak self] (errorResponce) in
            DispatchQueue.main.async {
                if case ErrorResponse.error(let error) = errorResponce, error is URLError {
                    UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
                } else {
                    self?.output.onFailEULA()
                }
            }
        }
    }
    
    func clearAllPreviouslyStoredInfo() {
        CoreDataStack.default.clearDataBase()
    }
}
