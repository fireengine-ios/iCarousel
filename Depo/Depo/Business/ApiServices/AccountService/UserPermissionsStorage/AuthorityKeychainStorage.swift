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
    
    private let isPremiumKey = "AUTH_PREMIUM_USER"
    private let faceRecognitionKey = "AUTH_FACE_IMAGE_LOCATION"
    private let deleteDublicateKey = "AUTH_DELETE_DUPLICATE"
    
    private lazy var keychain = KeychainSwift()
    
    var isPremium: String? {
        get {
            guard let isPremiumValue = keychain.get(isPremiumKey) else {
                return nil
            }
            return isPremiumValue
        }
        set {
            keychain.set(newValue, forKey: isPremiumKey, withAccess: .accessibleAfterFirstUnlock)
        }
    }
    
    var faceRecognition: String? {
        get {
            guard let faceRecognition = keychain.get(faceRecognitionKey) else {
                return nil
            }
            return faceRecognition
        }
        
        set {
            keychain.set(newValue, forKey: faceRecognitionKey, withAccess: .accessibleAfterFirstUnlock)
        }
    }
    
    var deleteDublicate: String? {
        get {
            guard let deleteDublicate = keychain.get(deleteDublicateKey) else {
                return nil
            }
            return deleteDublicate
        }
        
        set {
            keychain.set(newValue, forKey: deleteDublicateKey, withAccess: .accessibleAfterFirstUnlock)
        }
    }
    
    func refrashStatus(permissions: PermissionsResponse) {
        faceRecognition = permissions.hasPermissionFor(.faceRecognition) ? faceRecognitionKey : nil
        deleteDublicate = permissions.hasPermissionFor(.deleteDublicate) ? deleteDublicateKey : nil
        isPremium = permissions.hasPermissionFor(.premiumUser) ? isPremiumKey : nil
    }
    
    init() {
    }
}
