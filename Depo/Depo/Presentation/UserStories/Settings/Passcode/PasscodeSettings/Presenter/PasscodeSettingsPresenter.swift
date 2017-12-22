//
//  PasscodeSettingsPasscodeSettingsPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PasscodeSettingsPresenter {
    weak var view: PasscodeSettingsViewInput?
    var interactor: PasscodeSettingsInteractorInput!
    var router: PasscodeSettingsRouterInput!
}

// MARK: PasscodeSettingsViewOutput
extension PasscodeSettingsPresenter: PasscodeSettingsViewOutput {
    
    func viewIsReady() {
    }
    
    func changePasscode() {
        if interactor.inNeedOfMailVerefication {
            view?.presentMailVerefication()
        } else {
            router.changePasscode(isTurkCellUser: interactor.isTurkcellUserFlag)
        }
        
    }
    
    func setTouchId(enable: Bool) {
        if interactor.inNeedOfMailVerefication {
            view?.presentMailVerefication()
        } else {
            isBiometricsEnabled = enable
        }
        
    }
    
    func turnOffPasscode() {
        interactor.clearPasscode()
        view?.setup(state: .set, animated: true)
    }
    
    func setPasscode() {
        if interactor.inNeedOfMailVerefication {
            view?.presentMailVerefication()
        } else {
            router.setPasscode(isTurkCellUser: interactor.isTurkcellUserFlag)
        }
    }
    
    var isPasscodeEmpty: Bool {
        return interactor.isPasscodeEmpty
    }
    
    var biometricsStatus: BiometricsStatus {
        return interactor.biometricsStatus
    }
    
    var isBiometricsEnabled: Bool {
        get { return interactor.isBiometricsEnabled }
        set { interactor.isBiometricsEnabled = newValue }
    }
    
    var isAvailableFaceID: Bool {
        return interactor.isAvailableFaceID
    }
    
    func mailVerified() {
        interactor.inNeedOfMailVerefication = false
    }
}

// MARK: PasscodeSettingsInteractorOutput
extension PasscodeSettingsPresenter: PasscodeSettingsInteractorOutput {

}

// MARK: PasscodeSettingsModuleInput
extension PasscodeSettingsPresenter: PasscodeSettingsModuleInput {

}
