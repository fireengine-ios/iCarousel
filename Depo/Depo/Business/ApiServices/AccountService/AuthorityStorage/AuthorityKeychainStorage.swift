//
//  AuthorityKeychainStorage.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import KeychainSwift

final class AuthorityKeychainStorage: AuthorityStorage {

    private enum Keys {
        //Took from StorageVars to get userID instead of creating storageVars
        static let currentUserID = "CurrentUserIDKey"
        
        static let isPremium = "AUTH_PREMIUM_USER"
        static let faceRecognition = "AUTH_FACE_IMAGE_LOCATION"
        static let deleteDublicate = "AUTH_DELETE_DUPLICATE"

        static let isBannerShowedForPremium = "isBannerShowedForPremium"
        static let isLosePremiumStatus = "isLosePremiumStatus"
    }

    private var keychain = KeychainSwift()

    var isPremium: Bool? {

        willSet {
            let currentFlag = isPremium ?? false
            let newFlag = newValue ?? false

            if currentFlag != newFlag {
                let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""

                UserDefaults.standard.set(currentFlag, forKey: Keys.isLosePremiumStatus + userID)
            }
        }

        didSet {
            keychain.set(isPremium ?? false, forKey: Keys.isPremium)
        }
    }
    
    var faceRecognition: Bool? {
        didSet {
            keychain.set(faceRecognition ?? false, forKey: Keys.faceRecognition)
        }
    }
    
    var deleteDublicate: Bool? {
        didSet {
            keychain.set(deleteDublicate ?? false, forKey: Keys.deleteDublicate)
        }
    }
    
    var isBannerShowedForPremium: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isBannerShowedForPremium + userID)
    }

    var isLosePremiumStatus: Bool {
        let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
        return UserDefaults.standard.bool(forKey: Keys.isLosePremiumStatus + userID)
    }
    
    func hideBannerForSecondLogin() {
        if isPremium == true {
            let userID = UserDefaults.standard.string(forKey: Keys.currentUserID) ?? ""
            UserDefaults.standard.set(true, forKey: Keys.isBannerShowedForPremium + userID)
        }
    }
    
    func refrashStatus(premium: Bool, dublicates: Bool, faces: Bool) {
        faceRecognition = faces
        deleteDublicate = dublicates
        isPremium = premium
    }
    
    func restoreStats() {
        isPremium = nil
        faceRecognition = nil
        deleteDublicate = nil
    }
    
    init() {
        isPremium = keychain.getBool(Keys.isPremium)
        faceRecognition = keychain.getBool(Keys.faceRecognition)
        deleteDublicate = keychain.getBool(Keys.deleteDublicate)
    }
}
