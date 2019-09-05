//
//  AuthoritySingleton.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class AuthoritySingleton {
    
    enum AccountType {
        case premium
        case middle
        case standart
        
        var isPremium: Bool {
            return self == .premium
        }
        
        var isMiddle: Bool {
            return self == .middle
        }
        
        static func convert(from response: PermissionsResponse) -> AccountType {
            if response.hasPermissionFor(.premiumUser) {
                return .premium
            } else if response.hasPermissionFor(.middleUser) {
                return .middle
            } else {
                return .standart
            }
        }
    }
    
    private enum Keys {
        //Took from StorageVars to get userID instead of creating storageVars
        static let currentUserID = "CurrentUserIDKey"
        
        static let isBannerShowedForPremium = "isBannerShowedForPremium"
        static let isLosePremiumStatus = "isLosePremiumStatus"
        static let isShowPopupAboutPremiumAfterRegistration = "isShowPopupAboutPremiumAfterRegistration"
        static let isShowedPopupAboutPremiumAfterLogin = "isShowedPopupAboutPremiumAfterLogin"
        static let isShowPopupAboutPremiumAfterStartSync = "isShowPopupAboutPremiumAfterStartSync"
        static let isLoginAlready = "isLoginAlready"
        static let currentAppVersionKey = "currentAppVersionKey"
        static let isNewAppVersionKey = "isNewAppVersionKey"
    }
    
    static let shared: AuthoritySingleton = AuthoritySingleton()
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    var isNewAppVersion: Bool = false
    var deleteDublicate: Bool = false
    var faceRecognition: Bool = false
    
    var currentAppVersion: String? {
        get {
            ///if there is more then one account for device this logic save correct logic for all users
            let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
            return UserDefaults.standard.string(forKey: Keys.currentAppVersionKey + userID)
        }
        set {
            ///if there is more then one account for device this logic save correct logic for all users
            let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
            UserDefaults.standard.set(newValue, forKey: Keys.currentAppVersionKey + userID)
        }
    }
    
    var accountType: AccountType = .standart {
        willSet {
            let newType = newValue

            let isLosePremium = accountType != newType
            if isLosePremium {
                let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
                UserDefaults.standard.set(isLosePremium, forKey: Keys.isLosePremiumStatus + userID)
            }
        }
    }
    
    var isBannerShowedForPremium: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: Keys.isBannerShowedForPremium + userID)
    }
    
    var isLosePremiumStatus: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: Keys.isLosePremiumStatus + userID)
    }
    
    func hideBannerForSecondLogin() {
        let userID = SingletonStorage.shared.uniqueUserID
        
        let isHideBanner = accountType.isPremium
        UserDefaults.standard.set(isHideBanner, forKey: Keys.isBannerShowedForPremium + userID)
    }
    
    var isShowPopupAboutPremiumAfterRegistration: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: Keys.isShowPopupAboutPremiumAfterRegistration + userID) && !accountType.isPremium
    }
    
    func setShowPopupAboutPremiumAfterRegistration(isShow: Bool) {
        let userID = SingletonStorage.shared.uniqueUserID
        UserDefaults.standard.set(isShow, forKey: Keys.isShowPopupAboutPremiumAfterRegistration  + userID)
    }
    
    var isShowedPopupAboutPremiumAfterLogin: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: Keys.isShowedPopupAboutPremiumAfterLogin + userID)
    }
    
    func setShowedPopupAboutPremiumAfterLogin(isShow: Bool) {
        let userID = SingletonStorage.shared.uniqueUserID
        UserDefaults.standard.set(isShow, forKey: Keys.isShowedPopupAboutPremiumAfterLogin  + userID)
    }
    
    var isShowPopupAboutPremiumAfterSync: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: Keys.isShowPopupAboutPremiumAfterStartSync + userID) && !accountType.isPremium
    }
    
    func setShowPopupAboutPremiumAfterSync(isShow: Bool) {
        let userID = SingletonStorage.shared.uniqueUserID
        UserDefaults.standard.set(isShow, forKey: Keys.isShowPopupAboutPremiumAfterStartSync  + userID)
    }
    
    var isLoginAlready: Bool {
        return UserDefaults.standard.bool(forKey: Keys.isLoginAlready)
    }
    
    func setLoginAlready(isLoginAlready: Bool) {
        UserDefaults.standard.set(isLoginAlready, forKey: Keys.isLoginAlready)
    }
    
    func refreshStatus(with storage: PermissionsResponse) {
        deleteDublicate = storage.hasPermissionFor(.deleteDublicate)
        faceRecognition = storage.hasPermissionFor(.faceRecognition)
        
        accountType = AccountType.convert(from: storage)
    }
    
    func clear() {
        faceRecognition = false
        deleteDublicate = false
        
        accountType = .standart
        
        isNewAppVersion = false
    }
    
    func checkNewVersionApp() {
        if getAppVersion() != currentAppVersion {
            setLoginAlready(isLoginAlready: tokenStorage.refreshToken != nil)
            isNewAppVersion = currentAppVersion == nil ? false : true
            currentAppVersion = getAppVersion()
        }
    }
    
    func getBuildVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return ""
        }
        return version
    }
    
    // MARK: Utility methods
    private func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
}
