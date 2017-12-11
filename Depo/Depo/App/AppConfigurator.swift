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
        
        CoreDataStack.default.appendLocalMediaItems(nil)
        
        self.configureSDWebImage()
    }
    
    class private func configureSDWebImage() {
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024   // 100Mb
        SDImageCache.shared().config.maxCacheAge = 7 * 24 * 60 * 60     // 7 days
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
    
    //MARK: - settings bundle
    //Check original post here: https://medium.com/@abhimuralidharan/adding-settings-to-your-ios-app-cecef8c5497
    
    struct SettingsBundleKeys {
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    
    class func setVersionAndBuildNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
    //MARK:-------
}
