//
//  PasscodeSettingsPasscodeSettingsPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PasscodeSettingsPresenter: BasePresenter {
    weak var view: PasscodeSettingsViewInput?
    var interactor: PasscodeSettingsInteractorInput!
    var router: PasscodeSettingsRouterInput!
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: PasscodeSettingsViewOutput
extension PasscodeSettingsPresenter: PasscodeSettingsViewOutput {
    
    func viewIsReady() {
        startAsyncOperation()
        interactor.trackScreen()
        interactor.requestTurkcellSecurityState()
    }
    
    func changePasscode() {
        if interactor.inNeedOfMailVerification {
            view?.presentMailVerification()
        } else {
            router.changePasscode(isTurkCellUser: interactor.isTurkcellUserFlag)
        }
        
    }
    
    func setTouchId(enable: Bool) {
        if interactor.inNeedOfMailVerification {
            view?.presentMailVerification()
        } else {
            isBiometricsEnabled = enable
        }
        
    }
    
    func turnOffPasscode() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageResetPasscodeSuccess)
        interactor.clearPasscode()
        view?.setup(state: .set, animated: true)
    }
    
    func setPasscode() {
        if interactor.inNeedOfMailVerification {
            view?.presentMailVerification()
        } else {
            let isTurkcell = interactor.isTurkcellUserFlag
            router.setPasscode(isTurkCellUser: isTurkcell, finishCallBack: {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PasscodeScreen())
            })
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
        interactor.inNeedOfMailVerification = false
    }
    
    func updatedTwoFactorAuth(isEnabled: Bool) {
        // https://jira.turkcell.com.tr/browse/DE-12172
        startAsyncOperation()
        interactor.changeTurkcellSecurity(passcode: false, autoLogin: false, twoFactorAuth: isEnabled)
    }
}

// MARK: PasscodeSettingsInteractorOutput
extension PasscodeSettingsPresenter: PasscodeSettingsInteractorOutput {
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool) {
        asyncOperationSuccess()
        view?.updatedTwoFactorAuth(isEnabled: twoFactorAuth)
    }
    
    func failedToAcquireTurkcellSecurityState() {
        acquiredTurkcellSecurityState(passcode: interactor.turkcellPasswordOn,
                                      autoLogin: interactor.turkcellAutoLoginOn,
                                      twoFactorAuth: interactor.twoFactorAuth)
    }
    
    func changeTurkcellSecurityFailed(error: ErrorResponse) {
        asyncOperationSuccess()
        UIApplication.showErrorAlert(message: error.description)
    }
}

// MARK: PasscodeSettingsModuleInput
extension PasscodeSettingsPresenter: PasscodeSettingsModuleInput {

}
