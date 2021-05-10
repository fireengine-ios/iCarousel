//
//  FirebaseRemoteConfig.swift
//  Depo
//
//  Created by Konstantin Studilin on 14.12.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig


private struct RemoteConfigKeys {
    static let loginSupportAttempts = "login_support_form_treshold"
    static let signupSupportAttempts = "signup_support_form_treshold"
    static let printOptionEnabled = "print_option_enabled"
}


final class FirebaseRemoteConfig {
    static var shared = FirebaseRemoteConfig()
    
    private let remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 10
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "FirebaseRemoteConfigDefaults")
    }

    var printOptionEnabled: Bool {
        let key = RemoteConfigKeys.printOptionEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    func fetchAttemptsBeforeSupportOnLogin(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.loginSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue.intValue {
                debugLog("fetched \(attempts) attempts for \(fetchKey)")
                completion(attempts)
                return
            }
            
            let attempts = NumericConstants.showSupportViewAttempts
            debugLog("return constant = \(attempts) attempts for \(fetchKey)")
            completion(attempts)
        }
    }
    
    func fetchAttemptsBeforeSupportOnSignup(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.signupSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue.intValue {
                debugLog("fetched \(attempts) attempts for \(fetchKey)")
                completion(attempts)
                return
            }
            
            let attempts = NumericConstants.showSupportViewAttempts
            debugLog("return constant = \(attempts) attempts for \(fetchKey)")
            completion(attempts)
        }
    }

    func performInitialFetch() {
        debugLog("performing inital fetch")
        remoteConfig.fetchAndActivate { status, error in
            switch status {
            case .successFetchedFromRemote:
                debugLog("initial fetch: fetched new values")
            case .successUsingPreFetchedData:
                debugLog("initial fetch: using prefetched values")
            case .error:
                debugLog("initial fetch error: \(error?.description ?? "unknown")")
            }
        }
    }

    private func fetch(key: String, completion: @escaping VoidHandler) {
        debugLog("fetching value for \(key)")
        remoteConfig.fetchAndActivate { status, error in
            switch status {
                case .successFetchedFromRemote:
                    debugLog("fetched new value for \(key)")
                case .successUsingPreFetchedData:
                    debugLog("using prefetched value for \(key)")
                case .error:
                    debugLog("error: \(error?.description ?? "unknown")")
            }
            
            completion()
        }
    }
}
