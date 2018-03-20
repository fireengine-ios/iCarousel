//
//  SavingAttemptsCounterByUnigueUserID.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class SavingAttemptsCounterByUnigueUserID {
    
    private let userDefaultsKey: String
    private var attempts: Int {
        get { return UserDefaultsForUserID.shared.object(for: userDefaultsKey) as? Int ?? 0 }
        set { UserDefaultsForUserID.shared.set(newValue, for: userDefaultsKey) }
    }
    
    private let limit: Int
    
    init(limit: Int, userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        self.limit = limit
    }
    
    @discardableResult
    func up(limitHandler: @escaping VoidHandler) -> Bool {
        attempts += 1
        if attempts >= limit {
            reset()
            limitHandler()
            return false
        }
        return true
    }
    
    func reset() {
        attempts = 0
    }
}
