//
//  SettingsBundleHelper.swift
//  Depo
//
//  Created by Aleksandr on 4/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SettingsBundleHelper {
    fileprivate struct BundleKeys {
        static let routeEnvironment = "routeEnvironment"
        static let version = "version_preference"
        static let buildVersion = "build_preference"
    }
    
    private struct EnviromentKeys {
        static let prod = "prod"
        static let preProd = "preprod"
        static let test = "test"
    }
    
    static let shared = {
        return SettingsBundleHelper()
    }
    
    var observer: NSKeyValueObservation?
    
    //MARK: - lifecycle
    
    deinit {
        observer?.invalidate()
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
    
    //MARK: - Instance related activities
    
    func startObservingForLifeTech() {
        if SettingsBundleHelper.isLifeTechBuild {
            startObserving()
        }
    }
    
    private func startObserving() {
//        return
        observer = UserDefaults.standard.observe(\.routeServerEnvironment, changeHandler: { (userDefaults, result) in
        debugPrint("===HERE WE GO===")
        })
//         UserDefaults.standard.observe(<#T##keyPath: KeyPath<UserDefaults, Value>##KeyPath<UserDefaults, Value>#>, changeHandler: <#T##(UserDefaults, NSKeyValueObservedChange<Value>) -> Void#>)
    }
    
}

extension UserDefaults {
    @objc dynamic var routeServerEnvironment: String {
        return string(forKey: SettingsBundleHelper.BundleKeys.routeEnvironment) ?? ""
    }
    
    
}
