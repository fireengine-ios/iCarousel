//
//  LoginSettingsInteractorIO.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginSettingsInteractorInput: class {
    var turkcellPasswordOn: Bool { get }
    var turkcellAutoLoginOn: Bool { get }
    var twoFactorAuth: Bool { get }
    
    var isPasscodeEnabled: Bool { get }
    
    func requestTurkcellSecurityState()
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool)
    func trackScreen()
}

protocol LoginSettingsInteractorOutput: class {
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool)
    func failedToAcquireTurkcellSecurityState()
    func changeTurkcellSecurityFailed(error: ErrorResponse)
}
