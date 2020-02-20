//
//  SettingsBundleHelper.swift
//  Depo
//
//  Created by Aleksandr on 4/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SettingsBundleHelper: NSObject {
    
    private struct BundleKeys {
        static let routeEnvironment = "routeEnvironment"
        static let version = "version_preference"
        static let buildVersion = "build_preference"
        static let dropDB = "dropDBState"
    }

    private struct EnviromentKeys {
        static let prod = "prod"
        static let preProd = "preprod"
        static let test = "test"
    }
    
    static let shared = SettingsBundleHelper()
    
    //MARK: - lifecycle
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: BundleKeys.routeEnvironment)
        UserDefaults.standard.removeObserver(self, forKeyPath: BundleKeys.dropDB)
    }
    
    //MARK: - Instance related activities
    
    func lifeTechSetup() {
        if SettingsBundleHelper.isDebugBundleEnabled {
            setCurrentRouteEnvironment()
            startObserving()
        }
    }
    
    private func setCurrentRouteEnvironment() {
        let newEnvironment = getPreferredEnvironment()
        RouteRequests.currentServerEnvironment = newEnvironment
    }
    
    func getPreferredEnvironment() -> RouteRequests.ServerEnvironment {
        guard let status = UserDefaults.standard.string(forKey: BundleKeys.routeEnvironment) else {
            return RouteRequests.ServerEnvironment.production
        }
        switch status {
        case EnviromentKeys.preProd:
            return RouteRequests.ServerEnvironment.preProduction
        case EnviromentKeys.test:
            return RouteRequests.ServerEnvironment.test
        default:
            return RouteRequests.ServerEnvironment.production
        }
    }
    
    private func checkDropDBStatusChange() {
        let currentDropDBState = UserDefaults.standard.bool(forKey: BundleKeys.dropDB)
        if currentDropDBState {
            MediaItemOperationsService.shared.deleteAllEnteties { _ in
                UserDefaults.standard.set(false, forKey: BundleKeys.dropDB)
                AppConfigurator.logout()
            }
        }
    }
    
    //MARK: - Observer
    
    private func startObserving() {
        UserDefaults.standard.addObserver(self, forKeyPath: BundleKeys.routeEnvironment, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: BundleKeys.dropDB, options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case BundleKeys.routeEnvironment:
            setCurrentRouteEnvironment()
            exit(EXIT_SUCCESS)
        case BundleKeys.dropDB:
            checkDropDBStatusChange()
        default:
            assertionFailure("\(keyPath ?? "nil")")
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
    
    private static var isDebugBundleEnabled: Bool {
        #if DEBUG_BUNDLE_ENABLED
        return true
        #endif
        return false
    }
}
