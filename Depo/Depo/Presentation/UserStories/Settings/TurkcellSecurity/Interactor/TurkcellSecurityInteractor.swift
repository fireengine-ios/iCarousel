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
    
//    var inNeedOfMail: Bool?
    
//    if self.isTurkcellUser {
//          array[1].append(contentsOf: [TextConstants.settingsViewCellTurkcellPasscode,
//          TextConstants.settingsViewCellTurkcellAutoLogin])
//    }
//    private func requestTurkcellSecurityInfo() {
//        AccountService().securitySettingsInfo(success: { [weak self] (response) in
//            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
//                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
//                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
//                    return
//            }
//            DispatchQueue.main.async {
//                self?.output.turkCellSecuritySettingsAccuered(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
//            }
//
//        }) { (error) in
//
//        }
//    }
//
    
}

// MARK: TurkcellSecurityInteractorInput
extension TurkcellSecurityInteractor: TurkcellSecurityInteractorInput {
    func requestTurkcellSecurityState() {
        AccountService().securitySettingsInfo(success: { [weak self] (response) in
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
            
        }) { [weak self] (error) in
            DispatchQueue.main.async {
                self?.output?.failedToAcquireTurkcellSecurityState()
            }
        }
    }
    
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool) {
        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: passcode, mobileNetworkAuthEnabled: autoLogin, success: { [weak self] (response) in
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
        }) { [weak self] (error) in
            debugPrint("error")
            DispatchQueue.main.async {
                self?.output?.changeTurkcellSecurityFailed()
            }
        }
    }
    
    var turkcellPasswordOn: Bool {
        return turkcellPassword ?? false
    }
    var turkcellAutoLoginOn: Bool {
        return turkcellLogin ?? false
    }
}
