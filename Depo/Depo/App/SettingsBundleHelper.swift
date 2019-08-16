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
        static let dropDB = "dropDBState"
    }
    
    private struct PreviouslyStoredValuesKeys {
        static let routeEnvironment = "oldRouteEnvironment"
    }
    
    private struct EnviromentKeys {
        static let prod = "prod"
        static let preProd = "preprod"
        static let test = "test"
    }
    
    //MARK: - global related activities
    
    static func setVersionAndBuildNumber() {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            UserDefaults.standard.set(version, forKey: BundleKeys.version)
        }
        if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            UserDefaults.standard.set(build, forKey: BundleKeys.buildVersion)
        }
    }
    
    static func setCurrentRouteEnvironment() {
        let newEnvironment = preferredEnvironment()
        RouteRequests.currentServerEnvironment = newEnvironment
        storeNewEnviroment(state: newEnvironment)
    }
    
    static func preferredEnvironment() -> RouteRequests.ServerEnvironment {
        return getEnviromentForState(state: UserDefaults.standard.string(forKey: BundleKeys.routeEnvironment))
    }
    
    private static func getPreviouslyStoredEnviroment() -> RouteRequests.ServerEnvironment {
        return getEnviromentForState(state: UserDefaults.standard.string(forKey: PreviouslyStoredValuesKeys.routeEnvironment))
    }
    
    private static func storeNewEnviroment(state: RouteRequests.ServerEnvironment) {
        let valueToStore: String
        switch state {
        case .production:
            valueToStore = EnviromentKeys.prod
        case .preProduction:
            valueToStore = EnviromentKeys.preProd
        case .test:
            valueToStore = EnviromentKeys.test
        }
        UserDefaults.standard.set(valueToStore, forKey: PreviouslyStoredValuesKeys.routeEnvironment)
    }
    
    private static func getEnviromentForState(state: String?) -> RouteRequests.ServerEnvironment {
        guard let unwrapedStatus = state else {
            return RouteRequests.ServerEnvironment.production
        }
        switch unwrapedStatus {
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
    
    static func checkLifeTechSettings() {
        guard SettingsBundleHelper.isLifeTechBuild else {
            return
        }
        checkEnvironmentChange()
        checkDropDBStatusChange()
    }
    
    private static func checkEnvironmentChange() {
        let oldEnvironment = getPreviouslyStoredEnviroment()
        let newEnvironment = preferredEnvironment()
        if newEnvironment != oldEnvironment {
            RouteRequests.currentServerEnvironment = newEnvironment
            storeNewEnviroment(state: newEnvironment)
            
        }
    }
    
    private static func checkDropDBStatusChange() {
        let currentDropDBState = UserDefaults.standard.bool(forKey: BundleKeys.dropDB)
        if currentDropDBState {
            UserDefaults.standard.set(false, forKey: BundleKeys.dropDB)
            MediaItemOperationsService.shared.deleteAllEnteties { _ in
                AppConfigurator.logout()
            }
            return
        }
    }
    
}
