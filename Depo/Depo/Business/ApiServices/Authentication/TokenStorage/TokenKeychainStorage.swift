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
    
    private lazy var keychain = KeychainSwift()
    
    var accessToken: String? {
        get {
            guard let token = keychain.get(accessTokenKey) else {
                return nil
            }
            debugPrint("- accessToken", token)
            return token
        }
        set {
            #if MAIN_APP
            log.debug("new accessToken: \(newValue ?? "nil")")
            #endif
            keychain.set(newValue, forKey: accessTokenKey, withAccess: .accessibleAlways)
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
            #if MAIN_APP
            log.debug("new refreshToken: \(newValue ?? "nil")")
            #endif
            keychain.set(newValue, forKey: refreshTokenKey, withAccess: .accessibleAlways)
        }
    }
    
    var isRememberMe: Bool {
        get { return keychain.getBool(isRememberMeKey) ?? false }
        set { keychain.set(newValue, forKey: isRememberMeKey, withAccess: .accessibleAlways) }
    }
    
    var isClearTokens: Bool {
        get { return keychain.getBool(isClearTokensKey) ?? false }
        set { keychain.set(newValue, forKey: isClearTokensKey, withAccess: .accessibleAlways) }
    }
    
    func clearTokens() {
        #if MAIN_APP
        log.debug("clearTokens")
        #endif
        accessToken = nil
        refreshToken = nil
        isRememberMe = false
    }
}
