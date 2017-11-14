//
//  PasscodeEnterPasscodeEnterInteractor.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PasscodeEnterInteractor {
    weak var output: PasscodeEnterInteractorOutput?
    
    let passcodeStorage: PasscodeStorage
    
    init(passcodeStorage: PasscodeStorage = PasscodeStorageDefaults()) {
        self.passcodeStorage = passcodeStorage
    }
}

// MARK: PasscodeEnterInteractorInput
extension PasscodeEnterInteractor: PasscodeEnterInteractorInput {
    func isEqual(to passcode: String) -> Bool {
        return passcodeStorage.isEqual(to: passcode)
    }
    func save(passcode: String) {
        passcodeStorage.save(passcode: passcode)
    }
}
