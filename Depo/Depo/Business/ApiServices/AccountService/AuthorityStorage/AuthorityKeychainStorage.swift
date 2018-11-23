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
                UserDefaults.standard.set(currentFlag, forKey: Keys.isLosePremiumStatus)
                UserDefaults.standard.set(newFlag, forKey: Keys.isBannerShowedForPremium)
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
        return UserDefaults.standard.bool(forKey: Keys.isBannerShowedForPremium)
    }

    var isLosePremiumStatus: Bool {
        return UserDefaults.standard.bool(forKey: Keys.isLosePremiumStatus)
    }
    
    func refrashStatus(premium: Bool, dublicates: Bool, faces: Bool) {
        faceRecognition = faces
        deleteDublicate = dublicates
        isPremium = premium
    }
    
    init() {
        isPremium = keychain.getBool(Keys.isPremium)
        faceRecognition = keychain.getBool(Keys.faceRecognition)
        deleteDublicate = keychain.getBool(Keys.deleteDublicate)
    }
}
