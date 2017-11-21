//
//  SplashSplashInteractor.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SplashInteractor: SplashInteractorInput {

    weak var output: SplashInteractorOutput!
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }

    func startLoginInBackroung(){
        if ApplicationSession.sharedSession.session.rememberMe {
            authByRememberMe()
        } else {
            output.onFailLogin()
        }
    }
    
    private func authByRememberMe() {
        output.startAsyncOperation()
        
        let success: SuccessLogin = { [weak self] in
            self?.successLogin()
        }
        
        let fail: FailResponse = { [weak self] (failObject) in
            self?.failLogin()
        }
        
        AuthenticationService().authification(success: success, fail: fail)
    }
    
    func successLogin(){
        DispatchQueue.main.async {
            self.output.onSuccessLogin()
        }
    }
    
    func failLogin(){
        DispatchQueue.main.async {
            self.output.asyncOperationSucces()
            self.output.onFailLogin()
        }
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] (successResponce) in
            DispatchQueue.main.async {
                self?.output.asyncOperationSucces()
                self?.output.onSuccessEULA()
            }
        }) { [weak self] (errorResponce) in
            DispatchQueue.main.async {
                self?.output.asyncOperationSucces()
                self?.output.onFailEULA()
            }
        }
    }
    
    func clearAllPreviouslyStoredInfo() {
        CoreDataStack.default.clearDataBase()
    }
}
