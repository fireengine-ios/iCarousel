//
//  SavingAttemptsCounterByUnigueUserID.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class UserDefaultsForUserID {
    static func set(_ object: Any, for key: String) {
        var dict = UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
        dict[SingletonStorage.shared.unigueUserID] = object
        UserDefaults.standard.set(dict, forKey: key)
    }
    static func object(for key: String) -> Any? {
        let dict = UserDefaults.standard.object(forKey: key) as? [String: Any]
        return dict?[SingletonStorage.shared.unigueUserID]
    }
}

/// get 1 2 3
//return UserDefaultsForUserID.object(for: userDefaultsKey) as? Int ?? 0
//return UserDefaultsForUserID.shared[userDefaultsKey] as? Int ?? 0
//return UserDefaultsForUserID2(key: userDefaultsKey).object as? Int ?? 0

/// set 1 2 3
//UserDefaultsForUserID.set(newValue, for: userDefaultsKey)
//UserDefaultsForUserID.shared[userDefaultsKey] = newValue
//UserDefaultsForUserID2(key: userDefaultsKey).set(newValue)

//final class UserDefaultsForUserID2 {
//    let key: String
//    init(key: String) {
//        self.key = key
//    }
//    
//    func set(_ object: Any) {
//        var dict = UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
//        dict[SingletonStorage.shared.unigueUserID] = object
//        UserDefaults.standard.set(dict, forKey: key)
//    }
//    
//    var object: Any? {
//        let dict = UserDefaults.standard.object(forKey: key) as? [String: Any]
//        return dict?[SingletonStorage.shared.unigueUserID]
//    }
//}

    
//final class UserDefaultsForUserID3 {
//    static let shared = UserDefaultsForUserID()
//    
//    subscript(key: String) -> Any? {
//        get {
//            let dict = UserDefaults.standard.object(forKey: key) as? [String: Any]
//            return dict?[SingletonStorage.shared.unigueUserID]
//        }
//        set {
//            var dict = UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
//            dict[SingletonStorage.shared.unigueUserID] = newValue
//            UserDefaults.standard.set(dict, forKey: key)
//        }
//    }
//}

final class SavingAttemptsCounterByUnigueUserID {
    
    private let userDefaultsKey: String
    private var attempts: Int {
        get { return UserDefaultsForUserID.object(for: userDefaultsKey) as? Int ?? 0 }
        set { UserDefaultsForUserID.set(newValue, for: userDefaultsKey) }
    }
    
    private let limit: Int
    private let limitHandler: VoidHandler
    
    init(limit: Int,
         userDefaultsKey: String,
         limitHandler: @escaping VoidHandler)
    {
        self.userDefaultsKey = userDefaultsKey
        self.limit = limit
        self.limitHandler = limitHandler
    }
    
    func up() {
        attempts += 1
        if attempts >= limit {
            reset()
            limitHandler()
        }
    }
    
    func reset() {
        attempts = 0
    }
}
