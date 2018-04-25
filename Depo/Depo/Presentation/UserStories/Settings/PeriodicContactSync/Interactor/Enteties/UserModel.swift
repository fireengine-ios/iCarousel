//
//  UserModel.swift
//  Depo
//
//  Created by Brothers Harhun on 25.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//


import Foundation

struct UserModel {
    let id: String
    var contactSyncSettings: PeriodicContactsSyncSettings
    
    
    init(withUserId id: String, contactSyncSettings: PeriodicContactsSyncSettings) {
        self.id = id
        self.contactSyncSettings = contactSyncSettings
    }
    
}
