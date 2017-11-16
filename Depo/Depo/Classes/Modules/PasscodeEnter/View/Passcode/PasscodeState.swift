//
//  PasscodeState.swift
//  Passcode
//
//  Created by Bondar Yaroslav on 11/14/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

enum PasscodeFlow {
    case validate
    case create
    case setNew
    
    var startState: PasscodeState {
        switch self {
        case .validate:
            return ValidatePasscodeState()
        case .create:
            return CreatePasscodeState()
        case .setNew:
            return OldPasscodeState()
        }
    }
}

protocol PasscodeState {
    var title: String { get }
    var isBiometricsAllowed: Bool { get }
    func finish(with passcode: Passcode, manager: PasscodeManager)
}

final class ValidatePasscodeState: PasscodeState {
    let title = "Enter the password"
    let isBiometricsAllowed = true
    
    func finish(with passcode: Passcode, manager: PasscodeManager) {
        if manager.storage.isEqual(to: passcode) {
            manager.storage.numberOfTries = manager.maximumInccorectPasscodeAttempts
            manager.delegate?.passcodeLockDidSucceed(manager)
        } else {
            manager.storage.numberOfTries -= 1
            if manager.storage.numberOfTries == 0 {
                manager.delegate?.passcodeLockDidFailNumberOfTries(manager)
            }
            
            manager.delegate?.passcodeLockDidFail(manager)
        }
    }
}

final class OldPasscodeState: PasscodeState {
    let title = "Enter old password"
    let isBiometricsAllowed = false
    
    func finish(with passcode: Passcode, manager: PasscodeManager) {
        if manager.storage.isEqual(to: passcode) {
            manager.storage.numberOfTries = manager.maximumInccorectPasscodeAttempts
            manager.changeState(to: SetNewPasscodeState())
        } else {
            manager.storage.numberOfTries -= 1
            if manager.storage.numberOfTries == 0 {
                manager.delegate?.passcodeLockDidFailNumberOfTries(manager)
            }
            
            manager.delegate?.passcodeLockDidFail(manager)
        }
    }
}

class SetNewPasscodeState: PasscodeState {
    let title = "Enter new password"
    let isBiometricsAllowed = false
    
    func finish(with passcode: Passcode, manager: PasscodeManager) {
        let state = ConfirmNewPasscodeState(passcode: passcode)
        manager.changeState(to: state)
    }
}

class CreatePasscodeState: SetNewPasscodeState {
    override func finish(with passcode: Passcode, manager: PasscodeManager) {
        let state = ConfirmCreateingNewPasscodeState(passcode: passcode)
        manager.changeState(to: state)
    }
}



class ConfirmNewPasscodeState: PasscodeState {
    let title = "Confirm password"
    let isBiometricsAllowed = false
    
    let passcode: Passcode
    init(passcode: Passcode) {
        self.passcode = passcode
    }
    
    func finish(with passcode: Passcode, manager: PasscodeManager) {
        if self.passcode == passcode {
            manager.storage.save(passcode: passcode)
            manager.delegate?.passcodeLockDidSucceed(manager)
        } else {
            manager.changeState(to: OldPasscodeState())
            manager.delegate?.passcodeLockDidFail(manager)
        }
    }
}

class ConfirmCreateingNewPasscodeState: ConfirmNewPasscodeState {
    override func finish(with passcode: Passcode, manager: PasscodeManager) {
        if self.passcode == passcode {
            manager.storage.save(passcode: passcode)
            manager.delegate?.passcodeLockDidSucceed(manager)
        } else {
            manager.changeState(to: CreatePasscodeState())
            manager.delegate?.passcodeLockDidFail(manager)
        }
    }
}



