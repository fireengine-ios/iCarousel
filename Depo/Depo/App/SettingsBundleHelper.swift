//
//  SettingsBundleHelper.swift
//  Depo
//
//  Created by Aleksandr on 4/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SettingsBundleHelper {
    
    static func setVersionAndBuildNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
    
    static func preferredEnvironment() -> RouteRequests.ServerEnvironment {
        guard isLifeTechBuild,
            let selectedEnviroment = Bundle.main.object(forInfoDictionaryKey: "routeEnviroment") as? Int else {
                return RouteRequests.ServerEnvironment.production
        }
        switch selectedEnviroment {
        case 1:
            return RouteRequests.ServerEnvironment.preProduction
        case 2:
            return RouteRequests.ServerEnvironment.test
        default:
            return RouteRequests.ServerEnvironment.production
        }
    }
    
    private static var isLifeTechBuild: Bool {
        return ((Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String) == "by.come.life.Lifebox")
    }
    
}
