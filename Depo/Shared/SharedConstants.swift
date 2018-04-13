//
//  SharedConstants.swift
//  Depo
//
//  Created by Konstantin on 2/8/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


struct SharedConstants {
    private init() {}
    
    #if APPSTORE
    static let groupIdentifier = "group.com.turkcell.akillidepo"
    
    #elseif ENTERPRISE
    static let groupIdentifier = "group.com.turkcell.akillideponew.ent"
    
    #elseif DEBUG
    static let groupIdentifier = "group.come.life.Lifebox"
    
    #else
    static let groupIdentifier = "group.come.life.Lifebox"
    #endif
    
    
    static let wormholeDirectoryIdentifier = "wormhole"
    static let wormholeMessageIdentifier = "wormholeMessageIdentifier"
    static let wormholeCurrentImageIdentifier = "wormholeCurrentImageIdentifier"
    
    static let finishedAutoSyncCountKey = "finishedAutoSyncCount"
    static let totalAutoSyncCountKey = "totalAutoSyncCount"
    static let lastSyncDateKey = "lastSyncDate"
    static let syncStatusKey = "syncStatus"
    
    static let wormholeLogout = "wormholeLogout"
    static let wormholeOffTurkcellPassword = "wormholeOffTurkcellPassword"
}
