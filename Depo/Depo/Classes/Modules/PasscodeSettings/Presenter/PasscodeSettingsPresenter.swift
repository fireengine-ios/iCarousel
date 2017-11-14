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
        if PasscodeStorageDefaults().isEmpty {
            view?.setup(state: .set)
        } else {
            view?.setup(state: .ready)
        }
    }
    
    func changePasscode() {
        router.passcode(delegate: self, type: .setNew)
    }
    
    func setTouchId(enable: Bool) {
        TouchIdManager().isEnabledTouchId = enable
    }
    
    func turnOffPasscode() {
        router.passcode(delegate: self, type: .validate)
    }
    
    func setPasscode() {
        router.passcode(delegate: self, type: .new)
    }
}

// MARK: PasscodeSettingsInteractorOutput
extension PasscodeSettingsPresenter: PasscodeSettingsInteractorOutput {

}

// MARK: PasscodeSettingsModuleInput
extension PasscodeSettingsPresenter: PasscodeSettingsModuleInput {

}

// MARK: PasscodeEnterDelegate
extension PasscodeSettingsPresenter: PasscodeEnterDelegate {
    func finishPasscode(with type: PasscodeInputViewType) {
        router.closePasscode()
        switch type {
        case .new:
            view?.setup(state: .ready)
        case .validate, .validateWithBiometrics:
            PasscodeStorageDefaults().clearPasscode()
            view?.setup(state: .set)
        case .validateNew:
            break
        case .setNew:
            break
        }
        
    }
}
