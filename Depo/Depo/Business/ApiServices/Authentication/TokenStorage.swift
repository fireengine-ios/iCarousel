//
//  TokenStorage.swift
//  NetworingAuth
//
//  Created by Yaroslav Bondar on 06.02.17.
//  Copyright © 2017 Yaroslav Bondar. All rights reserved.
//

import Foundation

protocol TokenStorage: class {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

final class TokenStorageUserDefaults: TokenStorage {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    var accessToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: accessTokenKey) else {
                return nil
            }
            print("- accessToken", token)
            return token
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: refreshTokenKey) else {
                return nil
            }
            print("- refreshToken", token)
            return token
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey)
        }
    }
}
