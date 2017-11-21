//
//  PasscodeSettingsInteractorIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeSettingsInteractorInput: class {
    func clearPasscode()
    var isPasscodeEmpty: Bool { get }
    var isBiometricsAvailable: Bool { get }
    var isBiometricsEnabled: Bool { get set }
    var isAvailableFaceID: Bool { get }
}

protocol PasscodeSettingsInteractorOutput: class {

}
