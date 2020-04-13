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
    var autoSyncSet: Bool { get set }
    var autoSyncSettings: [String: Any]? { get set }
    var autoSyncSettingsMigrationCompleted: Bool { get set }
    var smallFullOfQuotaPopUpCheckBox: Bool { get set }
    var largeFullOfQuotaPopUpCheckBox: Bool { get set }
    var largeFullOfQuotaPopUpShownBetween80And99: Bool { get set }
    var largeFullOfQuotaPopUpShowType100: Bool { get set }
    var largeFullOfQuotaUserPremium: Bool { get set }
    var periodicContactSyncSet: Bool { get set }
    var usersWhoUsedApp: [String: Any] { get set }
    var isNewAppVersionFirstLaunchTurkcellLanding: Bool { get set }
    var deepLink: String? { get set }
    var deepLinkParameters: [AnyHashable: Any]? { get set }
    var blockedUsers: [String : Date] { get set }
    var shownCampaignInstaPickWithDaysLeft: Date? { get set }
    var shownCampaignInstaPickWithoutDaysLeft: Date? { get set }
    var hiddenPhotoInPeopleAlbumPopUpCheckBox: Bool { get set }
    var smashPhotoPopUpCheckBox: Bool { get set }
    var smartAlbumWarningPopUpCheckBox: Bool { get set }
    var interruptedResumableUploads: [String: Any] { get set }
    var isResumableUploadEnabled: Bool? { get set }
    var resumableUploadChunkSize: Int? { get set }
    var lastUnsavedFileUUID: String? { get set }
}

final class UserDefaultsVars: StorageVars {
    
    private let userDefaults = UserDefaults.standard
    
    private let isAppFirstLaunchKey = "isAppFirstLaunchKey"
    var isAppFirstLaunch: Bool {
        get { return userDefaults.object(forKey: isAppFirstLaunchKey) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: isAppFirstLaunchKey) }
    }
    
    ///Do not change key
    private let isNewAppVersionFirstLaunchKey = "isNewAppVersionFirstLaunch%@"
    var isNewAppVersionFirstLaunchTurkcellLanding: Bool {
        get {
            return userDefaults.object(forKey: String(format: isNewAppVersionFirstLaunchKey, getAppVersion())) as? Bool ?? true
        }
        set {
            userDefaults.set(newValue, forKey: String(format: isNewAppVersionFirstLaunchKey, getAppVersion()))
        }
    }
    
    private func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
    
    private let currentAppVersionKey = "currentAppVersionKey"
    var currentAppVersion: String? {
        get { return userDefaults.string(forKey: currentAppVersionKey) }
        set { userDefaults.set(newValue, forKey: currentAppVersionKey) }
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
    
    private let periodicContactSyncSetKey = "PeriodicContactSyncSetSetKey"
    var periodicContactSyncSet: Bool {
        get { return userDefaults.bool(forKey: periodicContactSyncSetKey) }
        set { userDefaults.set(newValue, forKey: periodicContactSyncSetKey) }
    }
    
    private let autoSyncSettingsKey = "autoSyncSettingsKey"
    var autoSyncSettings: [String: Any]? {
        get { return userDefaults.dictionary(forKey: autoSyncSettingsKey) }
        set { userDefaults.set(newValue, forKey: autoSyncSettingsKey) }
    }
    
    private let usersWhoUsedAppKey = "usersWhoUsedAppKey"
    var usersWhoUsedApp: [String: Any] {
        get { return userDefaults.dictionary(forKey: usersWhoUsedAppKey) ?? [String: Any]() }
        set { userDefaults.set(newValue, forKey: usersWhoUsedAppKey) }
    }
    
    /// auto sync settings migration from the old app
    private let autoSyncSettingsMigrationCompletedKey = "autoSyncSettingsMigrationCompletedKey"
    var autoSyncSettingsMigrationCompleted: Bool {
        get { return userDefaults.bool(forKey: autoSyncSettingsMigrationCompletedKey) }
        set { userDefaults.set(newValue, forKey: autoSyncSettingsMigrationCompletedKey) }
    }
    
    private let smallFullOfQuotaPopUpCheckBoxKey = "smallFullOfQuotaPopUpCheckBox"
    var smallFullOfQuotaPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: smallFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: smallFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let largeFullOfQuotaPopUpCheckBoxKey = "largeFullOfQuotaPopUpCheckBox"
    var largeFullOfQuotaPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: largeFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: largeFullOfQuotaPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let largeFullOfQuotaPopUpShownBetween80And99Key = "largeFullOfQuotaPopUpShownBetween80And99"
    var largeFullOfQuotaPopUpShownBetween80And99: Bool {
        get { return userDefaults.bool(forKey: largeFullOfQuotaPopUpShownBetween80And99Key + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: largeFullOfQuotaPopUpShownBetween80And99Key + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let largeFullOfQuotaPopUpShowType100Key = "largeFullOfQuotaPopUpShowType100"
    var largeFullOfQuotaPopUpShowType100: Bool {
        get { return userDefaults.bool(forKey: largeFullOfQuotaPopUpShowType100Key + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: largeFullOfQuotaPopUpShowType100Key + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let largeFullOfQuotaUserPremiumKey = "largeFullOfQuotaUserPremium"
    var largeFullOfQuotaUserPremium: Bool {
        get { return userDefaults.bool(forKey: largeFullOfQuotaUserPremiumKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: largeFullOfQuotaUserPremiumKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    
    private let deepLinkKey = "deepLinkKey"
    var deepLink: String? {
        get { return userDefaults.object(forKey: deepLinkKey) as? String}
        set { userDefaults.set(newValue, forKey: deepLinkKey)}
    }
    
    private let deepLinkParametersKey = "deepLinkParametersKey"
    var deepLinkParameters: [AnyHashable: Any]? {
        get { return userDefaults.object(forKey: deepLinkParametersKey) as? [AnyHashable: Any]}
        set { userDefaults.set(newValue, forKey: deepLinkParametersKey)}
    }
    
    var currentRemotesPage: Int {
        get { return UserDefaults.standard.integer(forKey: Keys.lastRemotesPageSaved) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastRemotesPageSaved) }
    }
    
    private let blockedUsersKey = "BlockedUsers"
    var blockedUsers: [String : Date] {
        get { return userDefaults.object(forKey: blockedUsersKey) as? [String : Date] ?? [:]}
        set { userDefaults.set(newValue, forKey: blockedUsersKey)}
    }
    
    private let showCampaignInstaPickWithDaysLeftKey = "campaignShown"
    var shownCampaignInstaPickWithDaysLeft: Date? {
        get { return userDefaults.object(forKey: showCampaignInstaPickWithDaysLeftKey + SingletonStorage.shared.uniqueUserID) as? Date }
        set { userDefaults.set(newValue, forKey: showCampaignInstaPickWithDaysLeftKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let showCampaignInstaPickWithoutDaysLeftKey = "campaignShownWithoutDaysLeft"
    var shownCampaignInstaPickWithoutDaysLeft: Date? {
        get { return userDefaults.object(forKey: showCampaignInstaPickWithoutDaysLeftKey + SingletonStorage.shared.uniqueUserID) as? Date }
        set { userDefaults.set(newValue, forKey: showCampaignInstaPickWithoutDaysLeftKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let hiddenPhotoInPeopleAlbumPopUpCheckBoxKey = "hiddenPhotoInPeopleAlbumPopUpCheckBox"
    var hiddenPhotoInPeopleAlbumPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: hiddenPhotoInPeopleAlbumPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: hiddenPhotoInPeopleAlbumPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let smashPhotoPopUpCheckBoxKey = "smashPhotoPopUpCheckBox"
    var smashPhotoPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: smashPhotoPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: smashPhotoPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let smartAlbumWarningPopUpCheckBoxKey = "smartAlbumWarningPopUpCheckBox"
    var smartAlbumWarningPopUpCheckBox: Bool {
        get { return userDefaults.bool(forKey: smartAlbumWarningPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
        set { userDefaults.set(newValue, forKey: smartAlbumWarningPopUpCheckBoxKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let interruptedResumableUploadsKey = "interruptedResumableUploads"
    var interruptedResumableUploads: [String : Any] {
        get { return userDefaults.dictionary(forKey: interruptedResumableUploadsKey + SingletonStorage.shared.uniqueUserID) ?? [:] }
        set { userDefaults.set(newValue, forKey: interruptedResumableUploadsKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let lastUnsavedFileUUIDKey = "lastUnsavedFileUUID"
    var lastUnsavedFileUUID: String? {
        get { return userDefaults.object(forKey: lastUnsavedFileUUIDKey) as? String}
        set { userDefaults.set(newValue, forKey: lastUnsavedFileUUIDKey)}
    }
    
    private let isResumableUploadEnabledKey = "isResumableUploadEnabled"
    var isResumableUploadEnabled: Bool? {
        get { return userDefaults.value(forKey: isResumableUploadEnabledKey + SingletonStorage.shared.uniqueUserID) as? Bool }
        set { userDefaults.set(newValue, forKey: isResumableUploadEnabledKey + SingletonStorage.shared.uniqueUserID) }
    }
    
    private let resumableUploadChunkSizeKey = "resumableUploadChunkSize"
    var resumableUploadChunkSize: Int? {
        get { return userDefaults.value(forKey: resumableUploadChunkSizeKey + SingletonStorage.shared.uniqueUserID) as? Int }
        set { userDefaults.set(newValue, forKey: resumableUploadChunkSizeKey + SingletonStorage.shared.uniqueUserID) }
    }
}
