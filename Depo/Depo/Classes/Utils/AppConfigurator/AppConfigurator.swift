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
    
    @objc class func applicationStarted(){
        ApplicationSessionManager.start()
        
        let dbSession = DBSession.init(appKey: "422fptod5dlxrn8", appSecret: "umjclqg3juoyihd", root: kDBRootDropbox)
        DBSession.setShared(dbSession)
        
        CoreDataStack.default.appendLocalMediaItems()
        
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
        
        LocationManager.shared().startUpdateLocation()
        
    }
    
}
