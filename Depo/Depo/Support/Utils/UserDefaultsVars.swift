//
//  UserDefaultsVars.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class UserDefaultsVars {
    private static let userDefaults = UserDefaults.standard
    
    static let emailSavingAttemptsCounterKey = "EmailSavingAttemptsCounter"
    
    private static let currentUserIDKey = "CurrentUserIDKey"
    static var currentUserID: String? {
        get { return userDefaults.string(forKey: currentUserIDKey) }
        set { userDefaults.set(newValue, forKey: currentUserIDKey) }
    }
    
    /// need flag for SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
    /// when user logged in but drop app at EmailEnterController (func openEmptyEmail)
    /// used in AppConfigurator emptyEmailUpIfNeed()
    private static let emptyEmailUpKey = "emptyEmailUpKey"
    static var emptyEmailUp: Bool {
        get { return userDefaults.bool(forKey: emptyEmailUpKey) }
        set { userDefaults.set(newValue, forKey: emptyEmailUpKey) }
    }
}
