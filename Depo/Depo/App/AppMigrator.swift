//
//  AppMigrator.swift
//  Depo
//
//  Created by Oleg on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class AppMigrator {
    
    private static let migrationHasBeenCompleted = "application2018migrationKey"
    
    class func migrateFromOldApplicationIfNeed() {
        let userDefault = UserDefaults.standard
        let needTryToMigrate = !userDefault.bool(forKey: migrationHasBeenCompleted)
        
        if needTryToMigrate {
            userDefault.set(true, forKey: migrationHasBeenCompleted)
            
            var refreshToken = ""
            if let token = UserDefaults.standard.object(forKey: "REMEMBER_ME_TOKEN_KEY") as? String{
                refreshToken = token
            }
            
            if !refreshToken.isEmpty{
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.refreshToken = refreshToken
                tokenStorage.isRememberMe = true
            }
        }
    }
    
}
