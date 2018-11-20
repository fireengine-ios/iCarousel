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
    }

    private var keychain = KeychainSwift()

    var isPremium: Bool? {
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
    
    func refrashStatus(premium: Bool, deleteDublicate: Bool, faceRecognition: Bool) {
        self.faceRecognition = faceRecognition
        self.deleteDublicate = deleteDublicate
        isPremium = premium
    }
    
    init() {
        isPremium = keychain.getBool(Keys.isPremium)
        faceRecognition = keychain.getBool(Keys.faceRecognition)
        deleteDublicate = keychain.getBool(Keys.deleteDublicate)
    }
}
