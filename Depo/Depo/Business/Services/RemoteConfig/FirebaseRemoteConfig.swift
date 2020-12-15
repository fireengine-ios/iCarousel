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
    static let loginSupportAttempts = "login_support_from_treshold"
    static let signupSupportAttempts = "signup_support_from_treshold"
}


final class FirebaseRemoteConfig {
    static var shared = FirebaseRemoteConfig()
    
    private let remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "FirebaseRemoteConfigDefaults")
    }
    
    func fetchAttemptsBeforeSupportOnLogin(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.loginSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue?.intValue {
                completion(attempts)
                return
            }
            
            completion(NumericConstants.showSupportViewAttempts)
        }
    }
    
    func fetchAttemptsBeforeSupportOnSignup(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.signupSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue?.intValue {
                completion(attempts)
                return
            }
            
            completion(NumericConstants.showSupportViewAttempts)
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
