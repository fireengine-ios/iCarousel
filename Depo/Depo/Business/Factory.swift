//
//  Factory.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/16/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

let factory: Factory = FactoryMain()

protocol Factory {
    func resolve() -> MediaPlayer
    func resolve() -> DropboxManager
    func resolve() -> PasscodeStorage
    func resolve() -> BiometricsManager
    func resolve() -> TokenStorage
    func resolve() -> SessionManager
    
    func resolve() -> HomeCardsService
}

final class FactoryMain: Factory {
    
    private static let mediaPlayer = MediaPlayer()
    func resolve() -> MediaPlayer {
        return FactoryMain.mediaPlayer
    }
    
    private static let dropboxManager = DropboxManager()
    func resolve() -> DropboxManager {
        return FactoryMain.dropboxManager
    }
    
    private static let passcodeStorage = PasscodeStorageDefaults()
    func resolve() -> PasscodeStorage {
        return FactoryMain.passcodeStorage
    }
    
    private static let biometricsManager = BiometricsManagerImp()
    func resolve() -> BiometricsManager {
        return FactoryMain.biometricsManager
    }
    
    private static let tokenStorage = TokenStorageUserDefaults()
    func resolve() -> TokenStorage {
        return FactoryMain.tokenStorage
    }
    
    func resolve() -> SessionManager {
        return SessionManager.default
    }
}

/// services
extension FactoryMain {
    private static let homeCardsService = HomeCardsServiceImp(sessionManager: factory.resolve())
    func resolve() -> HomeCardsService {
        return FactoryMain.homeCardsService
    }
}
