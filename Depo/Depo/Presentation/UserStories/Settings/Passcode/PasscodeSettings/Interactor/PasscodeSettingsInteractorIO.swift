//
//  PasscodeSettingsInteractorIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsInteractorInput: AnyObject {
    func clearPasscode()
    func trackScreen()
    var isPasscodeEmpty: Bool { get }
    var biometricsStatus: BiometricsStatus { get }
    var isBiometricsEnabled: Bool { get set }
    var isAvailableFaceID: Bool { get }
    var inNeedOfMailVerification: Bool { get set }
    var isTurkcellUserFlag: Bool { get }
    var turkcellPasswordOn: Bool { get }
    var turkcellAutoLoginOn: Bool { get }
    var twoFactorAuth: Bool { get }
    
    var isPasscodeEnabled: Bool { get }
    
    func requestTurkcellSecurityState()
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool)
}

protocol PasscodeSettingsInteractorOutput: AnyObject {
    func acquiredTurkcellSecurityState(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool)
    func failedToAcquireTurkcellSecurityState()
    func changeTurkcellSecurityFailed(error: ErrorResponse)
}
