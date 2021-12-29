//
//  LoginSettingsPresenter.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class LoginSettingsPresenter: BasePresenter {
    weak var view: LoginSettingsViewInput?
    var interactor: LoginSettingsInteractorInput!
    var router: LoginSettingsRouterInput!
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    var cellsData = [SettingsTableViewSwitchCell.CellType: Bool]()
    let cellTypes: [SettingsTableViewSwitchCell.CellType]
    
    init(isTurkcell: Bool) {
        if isTurkcell {
            // https://jira.turkcell.com.tr/browse/DE-12172
            cellTypes = [/*.securityPasscode, .securityAutologin, */.twoFactorAuth]
        } else {
            cellTypes = [.twoFactorAuth]
        }
        
        super.init()
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: LoginSettingsViewOutput
extension LoginSettingsPresenter: LoginSettingsViewOutput {
    
    func viewIsReady() {
        startAsyncOperation()
        interactor.trackScreen()
        interactor.requestTurkcellSecurityState()
    }
    
    func updateStatus(type: SettingsTableViewSwitchCell.CellType, isOn: Bool) {
        
        cellsData.updateValue(isOn, forKey: type)
        
        switch type {
        case .securityPasscode:
            if interactor.isPasscodeEnabled, isOn, isOn != interactor.turkcellPasswordOn {
                router.presentErrorPopup(title: TextConstants.warning,
                                         message: TextConstants.turkcellSecurityWaringPasscode,
                                         buttonTitle: TextConstants.ok,
                                         buttonAction: { [weak self] in
                                            self?.updateStatuses()

                })
            } else {
                if !passcodeStorage.isEmpty, isOn {
                    router.presentErrorPopup(title: TextConstants.warning,
                                             message: TextConstants.turkcellSecurityWaringPasscode,
                                             buttonTitle: TextConstants.ok,
                                             buttonAction: nil)
                }
                
                updateStatuses()
            }
            
        case .securityAutologin:
            if interactor.isPasscodeEnabled, isOn, isOn != interactor.turkcellAutoLoginOn {
                router.presentErrorPopup(title: TextConstants.warning,
                                         message: TextConstants.turkcellSecurityWaringAutologin,
                                         buttonTitle: TextConstants.ok) { [weak self] in
                                            self?.updateStatuses()
                }
                
            } else {
                if !passcodeStorage.isEmpty, isOn {
                    router.presentErrorPopup(title: TextConstants.warning,
                                             message: TextConstants.turkcellSecurityWaringAutologin,
                                             buttonTitle: TextConstants.ok,
                                             buttonAction: nil)
                }
                updateStatuses()
            }
            
        case .twoFactorAuth:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.TwoFactorAuthentication(action: isOn ? .on : .off))
            updateStatuses()
        }
    }
    
    private func updateStatuses() {
        startAsyncOperation()
        interactor.changeTurkcellSecurity(passcode: cellsData[.securityPasscode] ?? false,
                                          autoLogin: cellsData[.securityAutologin] ?? false,
                                          twoFactorAuth: cellsData[.twoFactorAuth] ?? false)
    }
}

// MARK: LoginSettingsInteractorOutput
extension LoginSettingsPresenter: LoginSettingsInteractorOutput {
    func changeTurkcellSecurityFailed(error: ErrorResponse) {
        asyncOperationSuccess()

        UIApplication.showErrorAlert(message: error.description)
    }
    
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool) {
        asyncOperationSuccess()
        
        cellsData.updateValue(passcode, forKey: .securityPasscode)
        cellsData.updateValue(autoLogin, forKey: .securityAutologin)
        cellsData.updateValue(twoFactorAuth, forKey: .twoFactorAuth)

        view?.updateTableView()
    }
    
    func failedToAcquireTurkcellSecurityState() {
        acquiredTurkcellSecurityState(passcode: interactor.turkcellPasswordOn,
                                      autoLogin: interactor.turkcellAutoLoginOn,
                                      twoFactorAuth: interactor.twoFactorAuth)
    }
}
