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
    #endif
    #if ENTERPRISE
    static let groupIdentifier = "group.com.turkcell.akillideponew.ent"
    #endif
    #if DEBUG
    static let groupIdentifier = "group.come.life.Lifebox"
    #endif
    #if RELEASE
    static let groupIdentifier = "group.come.life.Lifebox"
    #endif
    
    //static let groupIdentifier = "group.come.life.Lifebox"
    
    static let wormholeDirectoryIdentifier = "wormhole"
    static let wormholeMessageIdentifier = "wormholeMessageIdentifier"
    static let wormholeCurrentImageIdentifier = "wormholeCurrentImageIdentifier"
    
    static let finishedAutoSyncCountKey = "finishedAutoSyncCount"
    static let totalAutoSyncCountKey = "totalAutoSyncCount"
    static let lastSyncDateKey = "lastSyncDate"
    static let syncStatusKey = "syncStatus"
}
