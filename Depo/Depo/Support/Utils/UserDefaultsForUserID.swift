//
//  UserDefaultsForUserID.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class UserDefaultsForUserID {
    private let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    func set(_ object: Any, for key: String) {
        var dict = UserDefaults.standard.object(forKey: userID) as? [String: Any] ?? [:]
        dict[key] = object
        UserDefaults.standard.set(dict, forKey: userID)
    }
    
    func object(for key: String) -> Any? {
        let dict = UserDefaults.standard.object(forKey: userID) as? [String: Any]
        return dict?[key]
    }
}
