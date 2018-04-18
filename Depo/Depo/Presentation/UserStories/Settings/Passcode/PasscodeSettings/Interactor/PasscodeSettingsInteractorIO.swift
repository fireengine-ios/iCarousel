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
    func setPasscode()
    var isPasscodeEmpty: Bool { get }
    var biometricsStatus: BiometricsStatus { get }
    var isBiometricsEnabled: Bool { get set }
    var isAvailableFaceID: Bool { get }
    var inNeedOfMailVerefication: Bool { get set }
    var isTurkcellUserFlag: Bool { get }
}

protocol PasscodeSettingsInteractorOutput: class {

}
