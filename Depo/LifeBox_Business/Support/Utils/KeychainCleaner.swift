//
//  KeychainCleaner.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 3/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import KeychainSwift

final class KeychainCleaner {
    private let unremovableValueKeys = ["deviceUUIDKey"]
    
    func clear() {
        let keychain = KeychainSwift()
        let unremovableValues = unremovableValueKeys.map { (key: $0, value: keychain.get($0)) }
        keychain.clear()
        unremovableValues.forEach { keychain.set($0.value, forKey: $0.key, withAccess: .accessibleAfterFirstUnlock) }
    }
}
