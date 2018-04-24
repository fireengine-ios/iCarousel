//
//  TokenStorageUserDefaults.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class TokenStorageUserDefaults: TokenStorage {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let isRememberMeKey = "isRememberMeKey"
    private let isClearTokensKey = "isClearTokensKey"
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    var accessToken: String? {
        get {
            guard let token = defaults?.string(forKey: accessTokenKey) else {
                return nil
            }
            print("- accessToken", token)
            return token
        }
        set {
            defaults?.setValue(newValue, forKey: accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = defaults?.string(forKey: refreshTokenKey) else {
                return nil
            }
            print("- refreshToken", token)
            return token
        }
        set {
            defaults?.setValue(newValue, forKey: refreshTokenKey)
        }
    }
    
    var isRememberMe: Bool {
        get { return UserDefaults.standard.bool(forKey: isRememberMeKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: isRememberMeKey) }
    }
    
    var isClearTokens: Bool {
        get { return UserDefaults.standard.bool(forKey: isClearTokensKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: isClearTokensKey) }
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        isRememberMe = false
    }
}
