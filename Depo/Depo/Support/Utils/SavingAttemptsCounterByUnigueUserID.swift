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
        get { return UserDefaultsForUserID.object(for: userDefaultsKey) as? Int ?? 0 }
        set { UserDefaultsForUserID.set(newValue, for: userDefaultsKey) }
    }
    
    private let limit: Int
    private let limitHandler: VoidHandler
    
    init(limit: Int,
         userDefaultsKey: String,
         limitHandler: @escaping VoidHandler)
    {
        self.userDefaultsKey = userDefaultsKey
        self.limit = limit
        self.limitHandler = limitHandler
    }
    
    func up() {
        attempts += 1
        if attempts >= limit {
            reset()
            limitHandler()
        }
    }
    
    func reset() {
        attempts = 0
    }
}
