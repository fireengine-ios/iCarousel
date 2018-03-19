//
//  SavingAttemptsCounter.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class SavingAttemptsCounter {
    
    private let userDefaultsKey: String
    private var attempts: Int {
        get { return UserDefaults.standard.integer(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
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
