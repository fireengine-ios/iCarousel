//
//  StorageVars.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol StorageVars: class {
    var isAppFirstLaunch: Bool { get set }
    var currentUserID: String? { get set }
    var emptyEmailUp: Bool { get set }
    var autoSyncSet: Bool { get set }
    var autoSyncSettings: [String: Any]? { get set }
    var autoSyncSettingsMigrationCompleted: Bool { get set }
    var homePageFirstTimeLogin: Bool { get set }
    var smallFullOfQuotaPopUpCheckBox: Bool { get set }
}

final class UserDefaultsVars: StorageVars {
    private let userDefaults = UserDefaults.standard
    
    private let isAppFirstLaunchKey = "isAppFirstLaunchKey"
    var isAppFirstLaunch: Bool {
        get { return userDefaults.object(forKey: isAppFirstLaunchKey) as? Bool ?? false }
        set { userDefaults.set(newValue, forKey: isAppFirstLaunchKey) }
    }
    
    private let currentUserIDKey = "CurrentUserIDKey"
    var currentUserID: String? {
        get { return userDefaults.string(forKey: currentUserIDKey) }
        set { userDefaults.set(newValue, forKey: currentUserIDKey) }
    }
    
    private let autoSyncSetKey = "AutoSyncSetKey"
    var autoSyncSet: Bool {
        get { return userDefaults.bool(forKey: autoSyncSetKey) }
        set { userDefaults.set(newValue, forKey: autoSyncSetKey) }
    }
    
    /// need flag for SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
    /// when user logged in but drop app at EmailEnterController (func openEmptyEmail)
    /// used in AppConfigurator emptyEmailUpIfNeed()
    private let emptyEmailUpKey = "emptyEmailUpKey"
    var emptyEmailUp: Bool {
        get { return userDefaults.bool(forKey: emptyEmailUpKey) }
        set { userDefaults.set(newValue, forKey: emptyEmailUpKey) }
    }
    
    private let autoSyncSettingsKey = "autoSyncSettingsKey"
    var autoSyncSettings: [String: Any]? {
        get { return userDefaults.dictionary(forKey: autoSyncSettingsKey) }
        set { userDefaults.set(newValue, forKey: autoSyncSettingsKey) }
    }
    
    /// auto sync settings migration from the old app
    private let autoSyncSettingsMigrationCompletedKey = "autoSyncSettingsMigrationCompletedKey"
    var autoSyncSettingsMigrationCompleted: Bool {
        get { return userDefaults.bool(forKey: autoSyncSettingsMigrationCompletedKey) }
        set { userDefaults.set(newValue, forKey: autoSyncSettingsMigrationCompletedKey) }
    }
    
    private let homePageFirstTimeKey = "firstTimeKeyLargeQuotaPopUp"
    var homePageFirstTimeLogin: Bool {
        get { return userDefaults.bool(forKey: homePageFirstTimeKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: homePageFirstTimeKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let smallFullOfQuotaPopUpCheckBoxKey = "smallFullOfQuotaPopUpCheckBox"
    var smallFullOfQuotaPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: smallFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: smallFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
}
