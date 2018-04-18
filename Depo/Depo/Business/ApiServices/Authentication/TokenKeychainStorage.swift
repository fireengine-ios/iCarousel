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
    
    private lazy var defaults = KeychainSwift()
    
    
    var accessToken: String? {
        get {
            guard let token = defaults.get(accessTokenKey) else {
                return nil
            }
            print("- accessToken", token)
            return token
        }
        set {
            defaults.set(newValue ?? "", forKey: accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = defaults.get(refreshTokenKey) else {
                return nil
            }
            print("- refreshToken", token)
            return token
        }
        set {
            defaults.set(newValue ?? "", forKey: refreshTokenKey)
        }
    }
    
    var isRememberMe: Bool {
        get { return defaults.getBool(isRememberMeKey) ?? false }
        set { defaults.set(newValue, forKey: isRememberMeKey) }
    }
    
    var isClearTokens: Bool {
        get { return defaults.getBool(isClearTokensKey) ?? false }
        set { defaults.set(newValue, forKey: isClearTokensKey) }
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        isRememberMe = false
    }
}
