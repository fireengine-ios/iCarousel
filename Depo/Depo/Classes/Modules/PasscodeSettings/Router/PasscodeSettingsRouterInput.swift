//
//  PasscodeSettingsPasscodeSettingsRouterInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsRouterInput {
    func passcode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType)
    func closePasscode()
}
