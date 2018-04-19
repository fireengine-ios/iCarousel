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
        
        let needTryToMigrate = !UserDefaults.standard.bool(forKey: migrationHasBeenCompleted)
        
        if needTryToMigrate {
            //UserDefaults.standard.set(true, forKey: migrationHasBeenCompleted)
            
            if let token = UserDefaults.standard.object(forKey: "REMEMBER_ME_TOKEN_KEY") as? String, !token.isEmpty{
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.refreshToken = token
                tokenStorage.isRememberMe = true
            }
        }
    }
    
}
