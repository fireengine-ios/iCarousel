//
//  TokenKeychainStorage.swift
//  Depo
//
//  Created by Oleg on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import KeychainSwift

final class TokenKeychainStorage: TokenStorage {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let isRememberMeKey = "isRememberMeKey"
    private let isClearTokensKey = "isClearTokensKey"
    
    private let keychain = KeychainSwift()
    
    private (set) var savedAccessToken: String?
    var accessToken: String? {
        get {
            guard let token = keychain.get(accessTokenKey) else {
                return nil
            }
            debugPrint("- accessToken", token)
            return token
        }
        set {
            /// accessibleWhenUnlocked is default for KeychainSwift
            /// You can use .accessibleAfterFirstUnlock if you need your app to access the keychain item while in the background. Note that it is less secure than the .accessibleWhenUnlocked option
            /// https://github.com/evgenyneu/keychain-swift#keychain_item_access
            keychain.set(newValue, forKey: accessTokenKey, withAccess: .accessibleAfterFirstUnlock)
            savedAccessToken = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = keychain.get(refreshTokenKey) else {
                return nil
            }
            debugPrint("- refreshToken", token)
            return token
        }
        set {
            keychain.set(newValue, forKey: refreshTokenKey, withAccess: .accessibleAfterFirstUnlock)
        }
    }
    
    var isRememberMe: Bool {
        get { return keychain.getBool(isRememberMeKey) ?? false }
        set { keychain.set(newValue, forKey: isRememberMeKey, withAccess: .accessibleAfterFirstUnlock) }
    }
    
    var isClearTokens: Bool {
        get { return keychain.getBool(isClearTokensKey) ?? false }
        set { keychain.set(newValue, forKey: isClearTokensKey, withAccess: .accessibleAfterFirstUnlock) }
    }
    
    init() {
        keychain.synchronizable = true
        savedAccessToken = accessToken
    }
    
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        isRememberMe = false
    }
}
