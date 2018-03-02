//
//  Factory.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/16/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

let factory: Factory = FactoryMain()

protocol Factory: SharedFactory {
    func resolve() -> MediaPlayer
    func resolve() -> DropboxManager
    func resolve() -> PasscodeStorage
    func resolve() -> BiometricsManager
    
    func resolve() -> HomeCardsService
}

final class FactoryMain: FactoryBase, Factory {
    
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
}

/// services
extension FactoryMain {
    private static let homeCardsService = HomeCardsServiceImp(sessionManager: factory.resolve())
    func resolve() -> HomeCardsService {
        return FactoryMain.homeCardsService
    }
}


