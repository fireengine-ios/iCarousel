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
            if isPremium ?? false == true, newValue ?? false == false {
                UserDefaults.standard.set(true, forKey: Keys.isLosePremiumStatus)
                UserDefaults.standard.set(false, forKey: Keys.isBannerShowedForPremium)
            } else if isPremium ?? false == false, newValue ?? false == true {
                UserDefaults.standard.set(false, forKey: Keys.isLosePremiumStatus)
                UserDefaults.standard.set(true, forKey: Keys.isBannerShowedForPremium)
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
        get {
            return UserDefaults.standard.bool(forKey: Keys.isBannerShowedForPremium)
        }
    }

    var isLosePremiumStatus: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLosePremiumStatus)
        }
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
