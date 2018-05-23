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
    
    func resolve() -> HomeCardsService
    
    func resolve() -> StorageVars
    
    func resolve() -> AnalyticsService
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
    
    private static let storageVars = UserDefaultsVars()
    func resolve() -> StorageVars {
        return FactoryMain.storageVars
    }
}

/// services
extension FactoryMain {
    private static let homeCardsService = HomeCardsServiceImp(sessionManager: factory.resolve())
    func resolve() -> HomeCardsService {
        return FactoryMain.homeCardsService
    }
    
    private static let analyticsService = AnalyticsService()
    func resolve() -> AnalyticsService {
        return FactoryMain.analyticsService
    }
}
