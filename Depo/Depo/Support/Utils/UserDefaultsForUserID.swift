//
//  UserDefaultsForUserID.swift
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
