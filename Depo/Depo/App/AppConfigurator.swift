//
//  AppConfigurator.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

class AppConfigurator {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    
    class func applicationStarted(){
//        ApplicationSessionManager.start()
        dropboxManager.start()
        
        CoreDataStack.default.appendLocalMediaItems(nil)
        
        self.configureSDWebImage()
        
        let urls: AuthorizationURLs = AuthorizationURLsImp()
        let tokenStorage: TokenStorage = TokenStorageUserDefaults()
        let auth: AuthorizationRepository = AuthorizationRepositoryImp(urls: urls, tokenStorage: tokenStorage)
        
        let sessionManager = SessionManager.default
        sessionManager.retrier = auth
        sessionManager.adapter = auth
    }
    
    class private func configureSDWebImage() {
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024   // 100Mb
        SDImageCache.shared().config.maxCacheAge = 7 * 24 * 60 * 60     // 7 days
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
    
}
