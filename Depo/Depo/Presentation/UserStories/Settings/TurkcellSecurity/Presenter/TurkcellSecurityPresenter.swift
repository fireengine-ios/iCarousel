//
//  TurkcellSecurityTurkcellSecurityPresenter.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TurkcellSecurityPresenter: BasePresenter {
    weak var view: TurkcellSecurityViewInput?
    var interactor: TurkcellSecurityInteractorInput!
    var router: TurkcellSecurityRouterInput!
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: TurkcellSecurityViewOutput
extension TurkcellSecurityPresenter: TurkcellSecurityViewOutput {
    func securityChanged(passcode: Bool, autoLogin: Bool) {
        startAsyncOperation()
        interactor.changeTurkcellSecurity(passcode: passcode, autoLogin: autoLogin)
    }
    
    func viewIsReady() {
        startAsyncOperation()
        interactor.requestTurkcellSecurityState()
    }
}

// MARK: TurkcellSecurityInteractorOutput
extension TurkcellSecurityPresenter: TurkcellSecurityInteractorOutput {
    func changeTurkcellSecurityFailed() {
        asyncOperationSucces()
        
    }
    
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool) {
        asyncOperationSucces()
        view?.setupSecuritySettings(passcode: passcode, autoLogin: autoLogin)
    }
    
    func failedToAcquireTurkcellSecurityState() {
        asyncOperationSucces()
        view?.setupSecuritySettings(passcode: interactor.turkcellPasswordOn, autoLogin: interactor.turkcellAutoLoginOn)
    }
//    func turkcellSecurityStatusNeeded(passcode: Bool, autoLogin: Bool) {
//        
//    }
//    
//    func turkcellSecurityChanged(passcode: Bool, autoLogin: Bool) {
//        interactor.changeTurkcellSecurity(passcode: passcode, autoLogin: autoLogin)
//    }
//    
//    func turkCellSecuritySettingsAccuered(passcode: Bool, autoLogin: Bool) {
//        view.changeTurkCellSecurity(passcode: passcode, autologin: autoLogin)
//    }
}

// MARK: TurkcellSecurityModuleInput
extension TurkcellSecurityPresenter: TurkcellSecurityModuleInput {

}
