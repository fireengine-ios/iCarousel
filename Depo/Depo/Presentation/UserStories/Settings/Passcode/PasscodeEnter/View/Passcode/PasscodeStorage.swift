//
//  PasscodeStorage.swift
//  Passcode
//
//  Created by Bondar Yaroslav on 10/2/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Foundation

public typealias Passcode = String

protocol PasscodeStorage: class {
    var isEmpty: Bool { get }
    func isEqual(to passcode: Passcode) -> Bool
    func save(passcode: Passcode)
    func clearPasscode()
    var passcode: Passcode { get }
    var numberOfTries: Int { get set }
}

final class PasscodeStorageDefaults {
    
    private lazy var defaults: UserDefaults? = {
        return UserDefaults(suiteName: SharedConstants.groupIdentifier)
    }()
    
    static let passcodeKey = "passcodeKey"
    var passcode: Passcode {
        get { return defaults?.string(forKey: PasscodeStorageDefaults.passcodeKey) ?? "" }
        set { defaults?.set(newValue, forKey: PasscodeStorageDefaults.passcodeKey) }
    }
    
    static let numberOfTriesKey = "numberOfTriesKey"
    var numberOfTries: Int {
        get { return defaults?.integer(forKey: PasscodeStorageDefaults.numberOfTriesKey) ?? 0 }
        set { defaults?.set(newValue, forKey: PasscodeStorageDefaults.numberOfTriesKey) }
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
