//
//  PasscodeStorage.swift
//  Passcode
//
//  Created by Bondar Yaroslav on 10/2/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Foundation

protocol PasscodeStorage: class {
    var isEmpty: Bool { get }
    func isEqual(to passcode: Passcode) -> Bool
    func save(passcode: Passcode)
    func clearPasscode()
    var passcode: Passcode { get }
    var numberOfTries: Int { get set }
}

final class PasscodeStorageDefaults {
    static let passcodeKey = "passcodeKey"
    var passcode: Passcode {
        get { return UserDefaults.standard.string(forKey: PasscodeStorageDefaults.passcodeKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: PasscodeStorageDefaults.passcodeKey) }
    }
    
    static let numberOfTriesKey = "numberOfTriesKey"
    var numberOfTries: Int {
        get { return UserDefaults.standard.integer(forKey: PasscodeStorageDefaults.numberOfTriesKey) }
        set { UserDefaults.standard.set(newValue, forKey: PasscodeStorageDefaults.numberOfTriesKey) }
    }
}
extension PasscodeStorageDefaults: PasscodeStorage {
    var isEmpty: Bool {
        return passcode.isEmpty
    }
    func isEqual(to passcode: Passcode) -> Bool {
        return passcode == self.passcode
    }
    
    func save(passcode: Passcode) {
        self.passcode = passcode
    }
    
    func clearPasscode() {
        passcode = ""
    }
}
