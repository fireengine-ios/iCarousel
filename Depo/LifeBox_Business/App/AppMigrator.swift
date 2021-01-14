//
//  AppMigrator.swift
//  Depo
//
//  Created by Oleg on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SQLite

final class AppMigrator {
    
    /// call migrate after Keychain clear
    static func migrateAll() {
        migrateTokens()
        migratePasscode()
        migratePasscodeTouchID()
    }
    
    static func migrateTokens() {
        guard let token = UserDefaults.standard.object(forKey: "REMEMBER_ME_TOKEN_KEY") as? String, !token.isEmpty else {
            return
        }
        
        debugLog("migrateTokens")
        
        let tokenStorage: TokenStorage = factory.resolve()
        tokenStorage.refreshToken = token
        tokenStorage.isRememberMe = true
        
        if tokenStorage.accessToken == nil {
            tokenStorage.accessToken = "" /// need not nil to get new token
        }
    }
    
    static func migratePasscode() {
        guard let passcodeMD5 = UserDefaults.standard.string(forKey: "ApplicationPasscode"), !passcodeMD5.isEmpty else {
            return
        }
        
        debugLog("migratePasscode")
        
        let passcodeStorage: PasscodeStorage = factory.resolve()
        passcodeStorage.save(passcode: passcodeMD5)
    }
    
    static func migratePasscodeTouchID() {
        let passcodeSetting = UserDefaults.standard.integer(forKey: "PassCodeSetting")
        let passcodeSettingOnWithTouchID = 2
        
        debugLog("migratePasscodeTouchID")
        
        if passcodeSetting == passcodeSettingOnWithTouchID {
            var biometricsManager: BiometricsManager = factory.resolve()
            biometricsManager.isEnabled = true
        }
    }
}
