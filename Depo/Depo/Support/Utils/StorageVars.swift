//
//  StorageVars.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol StorageVars: class {
    var currentUserID: String? { get set }
    var emptyEmailUp: Bool { get set }
}

final class UserDefaultsVars: StorageVars {
    private let userDefaults = UserDefaults.standard
    
    private let currentUserIDKey = "CurrentUserIDKey"
    var currentUserID: String? {
        get { return userDefaults.string(forKey: currentUserIDKey) }
        set { userDefaults.set(newValue, forKey: currentUserIDKey) }
    }
    
    /// need flag for SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
    /// when user logged in but drop app at EmailEnterController (func openEmptyEmail)
    /// used in AppConfigurator emptyEmailUpIfNeed()
    private let emptyEmailUpKey = "emptyEmailUpKey"
    var emptyEmailUp: Bool {
        get { return userDefaults.bool(forKey: emptyEmailUpKey) }
        set { userDefaults.set(newValue, forKey: emptyEmailUpKey) }
    }
}
