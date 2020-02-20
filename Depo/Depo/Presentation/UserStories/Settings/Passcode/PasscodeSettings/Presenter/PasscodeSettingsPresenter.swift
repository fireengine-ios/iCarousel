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
        interactor.trackScreen()
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
        MenloworksTagsService.shared.passcodeStatus(false)
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
                if isTurkcell {//end enebled???
                    let routerVC = RouterVC()
                    let popUP = PopUpController.with(title: TextConstants.warning, message: TextConstants.passcodeEneblingwWithActivatedTurkcellSecurity, image: .error, buttonTitle: TextConstants.ok)
                    routerVC.rootViewController?.present(popUP, animated: true, completion: nil)
                }
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
}

// MARK: PasscodeSettingsInteractorOutput
extension PasscodeSettingsPresenter: PasscodeSettingsInteractorOutput {

}

// MARK: PasscodeSettingsModuleInput
extension PasscodeSettingsPresenter: PasscodeSettingsModuleInput {

}
