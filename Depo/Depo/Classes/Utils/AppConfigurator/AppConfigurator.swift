//
//  AppConfigurator.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class AppConfigurator: NSObject {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    
    @objc class func applicationStarted(){
        ApplicationSessionManager.start()
        dropboxManager.start()
        
        CoreDataStack.default.appendLocalMediaItems()
        
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
        
    }
    
}
