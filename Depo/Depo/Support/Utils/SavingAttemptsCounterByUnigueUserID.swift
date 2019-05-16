//
//  SavingAttemptsCounterByUnigueUserID.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class SavingAttemptsCounterByUnigueUserID {
    
    private let userDefaultsForUserID: UserDefaultsForUserID
    private let userDefaultsKey: String
    
    private var attempts: Int {
        get { return userDefaultsForUserID.object(for: userDefaultsKey) as? Int ?? 0 }
        set { userDefaultsForUserID.set(newValue, for: userDefaultsKey) }
    }
    
    private let limit: Int
    var autoReset = false
    
    init(limit: Int, userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        self.limit = limit
        
        let storageVars: StorageVars = factory.resolve()
        let userID = storageVars.currentUserID ?? UUID().uuidString
        self.userDefaultsForUserID = UserDefaultsForUserID(userID: userID)
    }
    
    @discardableResult
    func up(limitHandler: @escaping VoidHandler) -> Bool {
        attempts += 1
        if attempts >= limit {
            if autoReset {
                reset()
            }
            limitHandler()
            return false
        }
        return true
    }
    
    func reset() {
        attempts = 0
    }
}
