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
    
//    private func showWarningPopUp
}

// MARK: TurkcellSecurityViewOutput
extension TurkcellSecurityPresenter: TurkcellSecurityViewOutput {
    func securityChanged(passcode: Bool, autoLogin: Bool) {
        
        if interactor.isPasscodeEnabled, passcode, passcode != interactor.turkcellPasswordOn {
            let router = RouterVC()
            let popUP = PopUpController.with(title: TextConstants.warning, message: TextConstants.turkcellSecurityWaringPasscode, image: .error, buttonTitle: TextConstants.ok, action: { [weak self] controller in
                self?.startAsyncOperation()
                self?.interactor.changeTurkcellSecurity(passcode: passcode, autoLogin: autoLogin)
                controller.close()
            })
            router.rootViewController?.present(popUP, animated: true, completion: nil)
        } else if interactor.isPasscodeEnabled, autoLogin, autoLogin != interactor.turkcellAutoLoginOn {
            let router = RouterVC()
            let popUP = PopUpController.with(title: TextConstants.warning, message: TextConstants.turkcellSecurityWaringAutologin, image: .error, buttonTitle: TextConstants.ok, action: { [weak self] controller in
                self?.startAsyncOperation()
                self?.interactor.changeTurkcellSecurity(passcode: passcode, autoLogin: autoLogin)
                controller.close()
            })
            router.rootViewController?.present(popUP, animated: true, completion: nil)
        } else {
            startAsyncOperation()
            
            if passcode != interactor.turkcellPasswordOn {
                MenloworksTagsService.shared.onTurkcellPasswordSettingsChanged(passcode)
            }
            
            if autoLogin != interactor.turkcellAutoLoginOn {
                MenloworksTagsService.shared.onAutoLoginSettingsChanged(autoLogin)
            }
                
            interactor.changeTurkcellSecurity(passcode: passcode, autoLogin: autoLogin)
        }
        
        
    }
    
    func viewIsReady() {
        startAsyncOperation()
        interactor.requestTurkcellSecurityState()
    }
}

// MARK: TurkcellSecurityInteractorOutput
extension TurkcellSecurityPresenter: TurkcellSecurityInteractorOutput {
    func changeTurkcellSecurityFailed(error: ErrorResponse) {
        UIApplication.showErrorAlert(message: error.localizedDescription)
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
}

// MARK: TurkcellSecurityModuleInput
extension TurkcellSecurityPresenter: TurkcellSecurityModuleInput {

}
