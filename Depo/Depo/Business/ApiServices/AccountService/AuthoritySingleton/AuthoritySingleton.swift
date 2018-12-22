//
//  AuthoritySingleton.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class AuthoritySingleton {
    
    static let shared: AuthoritySingleton = AuthoritySingleton()
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    private enum Keys {
        //Took from StorageVars to get userID instead of creating storageVars
        static let currentUserID = "CurrentUserIDKey"
        
        static let isBannerShowedForPremium = "isBannerShowedForPremium"
        static let isLosePremiumStatus = "isLosePremiumStatus"
        static let isShowPopupAboutPremiumAfterRegistration = "isShowPopupAboutPremiumAfterRegistration"
        static let isShowedPopupAboutPremiumAfterLogin = "isShowedPopupAboutPremiumAfterLogin"
        static let isShowedPopupAboutPremiumAfterSync = "isShowedPopupAboutPremiumAfterSync"
        static let isLoginAlready = "isLoginAlready"
        static let currentAppVersionKey = "currentAppVersionKey"
        static let isNewAppVersionKey = "isNewAppVersionKey"
    }
    
    var currentAppVersion: String? {
        get { return UserDefaults.standard.string(forKey: Keys.currentAppVersionKey) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.currentAppVersionKey) }
    }
    
    var isNewAppVersion: Bool = false
    
    var isPremium: Bool = false {
        willSet {
            let currentFlag = isPremium
            let newFlag = newValue
            
            if currentFlag != newFlag {
                let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
                UserDefaults.standard.set(currentFlag, forKey: Keys.isLosePremiumStatus + userID)
            }
        }
    }
    
    var deleteDublicate: Bool = false
    var faceRecognition: Bool = false

    var isBannerShowedForPremium: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isBannerShowedForPremium + userID)
    }
    
    var isLosePremiumStatus: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isLosePremiumStatus + userID)
    }
    
    func hideBannerForSecondLogin() {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        if isPremium == true {
            UserDefaults.standard.set(true, forKey: Keys.isBannerShowedForPremium + userID)
        } else {
            UserDefaults.standard.set(false, forKey: Keys.isBannerShowedForPremium + userID)
        }
    }
    
    var isShowPopupAboutPremiumAfterRegistration: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isShowPopupAboutPremiumAfterRegistration + userID) && isPremium == false
    }
    
    func setShowPopupAboutPremiumAfterRegistration(isShow: Bool) {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        UserDefaults.standard.set(isShow, forKey: Keys.isShowPopupAboutPremiumAfterRegistration  + userID)
    }
    
    var isShowedPopupAboutPremiumAfterLogin: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isShowedPopupAboutPremiumAfterLogin + userID)
    }
    
    func setShowedPopupAboutPremiumAfterLogin(isShow: Bool) {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        UserDefaults.standard.set(isShow, forKey: Keys.isShowedPopupAboutPremiumAfterLogin  + userID)
    }
    
    var isShowedPopupAboutPremiumAfterSync: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isShowedPopupAboutPremiumAfterSync + userID)
    }
    
    func setShowedPopupAboutPremiumAfterSync(isShow: Bool) {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        UserDefaults.standard.set(isShow, forKey: Keys.isShowedPopupAboutPremiumAfterSync  + userID)
    }
    
    var isLoginAlready: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isLoginAlready + userID)
    }
    
    func setLoginAlready(isLoginAlready: Bool) {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        UserDefaults.standard.set(isLoginAlready, forKey: Keys.isLoginAlready  + userID)
    }

    func refreshStatus(premium: Bool, dublicates: Bool, faces: Bool) {
        faceRecognition = faces
        deleteDublicate = dublicates
        isPremium = premium
    }
    
    func refreshStatus(with storage: PermissionsResponse) {
        isPremium = storage.hasPermissionFor(.premiumUser)
        deleteDublicate = storage.hasPermissionFor(.deleteDublicate)
        faceRecognition = storage.hasPermissionFor(.faceRecognition)
    }
    
    func clear() {
        isPremium = false
        faceRecognition = false
        deleteDublicate = false
    }
    
    func checkNewVersionApp() {
        if getAppVersion() != currentAppVersion {
            setLoginAlready(isLoginAlready: tokenStorage.refreshToken != nil)
            currentAppVersion = getAppVersion()
            isNewAppVersion = true
        }
    }
    
    // MARK: Utility methods
    private func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
}
