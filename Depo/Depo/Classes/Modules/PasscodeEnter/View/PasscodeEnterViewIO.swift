//
//  PasscodeEnterViewIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeEnterViewInput: class {
    func setPasscode(type: PasscodeInputViewType)
}

protocol PasscodeEnterViewOutput: class, PasscodeViewDelegate {
    func viewIsReady()
}
