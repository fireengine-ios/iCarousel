//
//  PasscodeSettingsViewIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsViewInput: class {
    func setup(state: PasscodeSettingsViewState)
}

protocol PasscodeSettingsViewOutput: class {
    func viewIsReady()
    func changePasscode()
    func setTouchId(enable: Bool)
    func turnOffPasscode()
    func setPasscode()
}
