//
//  PasscodeSettingsViewIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsViewInput: AnyObject {
    func setup(state: PasscodeSettingsViewState, animated: Bool)
    func presentMailVerification()
    func updatedTwoFactorAuth(isEnabled: Bool)
}

protocol PasscodeSettingsViewOutput: AnyObject {
    func viewIsReady()
    func changePasscode()
    func setTouchId(enable: Bool)
    func turnOffPasscode()
    func setPasscode()
    func mailVerified()
    func updatedTwoFactorAuth(isEnabled: Bool)
    
    var isPasscodeEmpty: Bool { get }
    var biometricsStatus: BiometricsStatus { get }
    var isBiometricsEnabled: Bool { get }
    var isAvailableFaceID: Bool { get }
}
