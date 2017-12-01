//
//  PasscodeSettingsViewIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsViewInput: class {
    func setup(state: PasscodeSettingsViewState, animated: Bool)
    func presentMailVerefication()
}

protocol PasscodeSettingsViewOutput: class {
    func viewIsReady()
    func changePasscode()
    func setTouchId(enable: Bool)
    func turnOffPasscode()
    func setPasscode()
    
    var isPasscodeEmpty: Bool { get }
    var isBiometricsAvailable: Bool { get }
    var isBiometricsEnabled: Bool { get }
    var isAvailableFaceID: Bool { get }
}
