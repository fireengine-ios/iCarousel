//
//  SharedFactory.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol SharedFactory {
    func resolve() -> TokenStorage
    func resolve() -> SessionManager
    func resolve() -> PasscodeStorage
}

open class FactoryBase: SharedFactory {
    
    private static let tokenStorage = TokenStorageUserDefaults()
    func resolve() -> TokenStorage {
        return FactoryBase.tokenStorage
    }
    
    func resolve() -> SessionManager {
        return SessionManager.default
    }
    
    private static let passcodeStorage = PasscodeStorageDefaults()
    func resolve() -> PasscodeStorage {
        return FactoryBase.passcodeStorage
    }
}

