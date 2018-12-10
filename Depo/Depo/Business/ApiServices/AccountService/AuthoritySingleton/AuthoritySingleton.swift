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
    
    private enum Keys {
        //Took from StorageVars to get userID instead of creating storageVars
        static let currentUserID = "CurrentUserIDKey"
        
        static let isBannerShowedForPremium = "isBannerShowedForPremium"
        static let isLosePremiumStatus = "isLosePremiumStatus"
    }
    
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
}
