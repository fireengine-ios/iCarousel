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
    func resolve() -> StorageVars
    func resolve() -> AuthorizationRepository
    
    func resolve() -> HomeCardsService
    func resolve() -> AnalyticsService
    func resolve() -> InstapickService
    func resolve() -> SpotifyService
    func resolve() -> SpotifyRoutingService

    func resolve() -> CoreDataStack
}

final class FactoryMain: FactoryBase, Factory {
    
    private static let coreDataStack: CoreDataStack = {
        if #available(iOS 10, *) {
            return CoreDataStack_ios10()
        } else {
            return CoreDataStack_ios9()
        }
    }()
    func resolve() -> CoreDataStack {
        return FactoryMain.coreDataStack
    }

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
    
    private static let authorizationRepository: AuthorizationRepository = {
        let urls: AuthorizationURLs = AuthorizationURLsImp()
        return AuthorizationRepositoryImp(urls: urls, tokenStorage: factory.resolve())
    }()
    func resolve() -> AuthorizationRepository {
        return FactoryMain.authorizationRepository
    }
    
    private static let instapickService = InstapickServiceImpl()
    func resolve() -> InstapickService {
        return FactoryMain.instapickService
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
    
    private static let spotifyService = SpotifyServiceImpl()
    func resolve() -> SpotifyService {
        return FactoryMain.spotifyService
    }
    
    private static let spotifyRoutingService = SpotifyRoutingService()
    func resolve() -> SpotifyRoutingService {
        return FactoryMain.spotifyRoutingService
    }
}
