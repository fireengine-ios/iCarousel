//
//  SettingsBundleHelper.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 12/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//
//Check original post here: https://medium.com/@abhimuralidharan/adding-settings-to-your-ios-app-cecef8c5497

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
}
