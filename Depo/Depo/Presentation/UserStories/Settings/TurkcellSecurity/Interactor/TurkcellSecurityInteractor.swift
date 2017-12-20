//
//  TurkcellSecurityTurkcellSecurityInteractor.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TurkcellSecurityInteractor {
    weak var output: TurkcellSecurityInteractorOutput?
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
//    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool) {
//        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: passcode, mobileNetworkAuthEnabled: autoLogin, success: { [weak self] (response) in
//            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
//                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
//                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
//                    return
//            }
//            DispatchQueue.main.async {
//                self?.output.turkCellSecuritySettingsAccuered(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
//            }
//            debugPrint("response")
//        }) { (error) in
//            debugPrint("error")
//        }
//    }
    
}

// MARK: TurkcellSecurityInteractorInput
extension TurkcellSecurityInteractor: TurkcellSecurityInteractorInput {

}
