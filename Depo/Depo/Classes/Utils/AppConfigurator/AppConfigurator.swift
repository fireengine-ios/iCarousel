//
//  AppConfigurator.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class AppConfigurator {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    
    class func applicationStarted(){
        ApplicationSessionManager.start()
        dropboxManager.start()
        
        CoreDataStack.default.appendLocalMediaItems()
        
        self.configureSDWebImage()
    }
    
    class private func configureSDWebImage() {
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024   // 100Mb
        SDImageCache.shared().config.maxCacheAge = 7 * 24 * 60 * 60     // 7 days
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
    
}
