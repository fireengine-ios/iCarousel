//
//  SettingsBundleHelper.swift
//  Depo
//
//  Created by Aleksandr on 4/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SettingsBundleHelper {
    private struct BundleKeys {
        static let routeEnvironment = "routeEnvironment"
        static let version = "version_preference"
        static let buildVersion = "build_preference"
    }
    
    private struct EnviromentKeys {
        static let prod = "prod"
        static let preProd = "preprod"
        static let test = "test"
    }
    
    //MARK: - global related activities
    
    static func setVersionAndBuildNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: BundleKeys.version)
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: BundleKeys.buildVersion)
    }
    
    static func preferredEnvironment() -> RouteRequests.ServerEnvironment {
        guard let selectedEnvironment = UserDefaults.standard.object(forKey: BundleKeys.routeEnvironment) as? String else {
            return RouteRequests.ServerEnvironment.production
        }
        switch selectedEnvironment {
        case EnviromentKeys.preProd:
            return RouteRequests.ServerEnvironment.preProduction
        case EnviromentKeys.test:
            return RouteRequests.ServerEnvironment.test
        default:
            return RouteRequests.ServerEnvironment.production
        }
    }
    
    private static var isLifeTechBuild: Bool {
        return ((Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String) == "by.come.life.Lifebox")
    }
    
    func checkLifeTechSettings() {
        guard SettingsBundleHelper.isLifeTechBuild else {
            return
        }
        
        
    }

}


