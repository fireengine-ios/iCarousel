//
//  KeychainSwift+Optional.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import KeychainSwift

extension KeychainSwift {
    
    @discardableResult
    func set(_ value: String?, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
        if let value = value {
            return set(value, forKey: key, withAccess: access)
        } else {
            delete(key)
            return false
        }
    }
}
