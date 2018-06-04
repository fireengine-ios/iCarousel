//
//  TurkcellSecurityTurkcellSecurityInteractor.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TurkcellSecurityInteractor {
    weak var output: TurkcellSecurityInteractorOutput?
    
    var turkcellPassword: Bool?
    var turkcellLogin: Bool?
    
    
    private let isEnabledKey = "isEnabledKey"
    private let passcodeKey = "passcodeKey"
    
    private var touchIDEnabled: Bool {
        return UserDefaults.standard.bool(forKey: isEnabledKey)
    }
    
    private var passcodeEnabled: Bool {
        guard let passcodeKey = UserDefaults.standard.string(forKey: self.passcodeKey) else {
            return false
        }
        return !passcodeKey.isEmpty
    }
    
}

// MARK: TurkcellSecurityInteractorInput
extension TurkcellSecurityInteractor: TurkcellSecurityInteractorInput {
    func requestTurkcellSecurityState() {
        AccountService().securitySettingsInfo(success: { [weak self] response in
            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
                    return
            }
            self?.turkcellPassword = turkCellPasswordOn
            self?.turkcellLogin = turkCellAutoLogin
            DispatchQueue.main.async {
                self?.output?.acquiredTurkcellSecurityState(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
            }
            
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.failedToAcquireTurkcellSecurityState()
            }
        }
    }
    
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool) {
        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: passcode, mobileNetworkAuthEnabled: autoLogin, success: { [weak self] response in
            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
                    return
            }
            DispatchQueue.main.async {
                self?.turkcellPassword = turkCellPasswordOn
                self?.turkcellLogin = turkCellAutoLogin
                self?.output?.acquiredTurkcellSecurityState(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
            }
            debugPrint("response")
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.changeTurkcellSecurityFailed(error: error)
            }
        }
    }
    
    var turkcellPasswordOn: Bool {
        return turkcellPassword ?? false
    }
    var turkcellAutoLoginOn: Bool {
        return turkcellLogin ?? false
    }
    var isPasscodeEnabled: Bool {
        return touchIDEnabled || passcodeEnabled
    }
}
