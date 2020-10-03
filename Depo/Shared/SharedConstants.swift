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
    static let wormholeNewWidgetStateIdentifier = "wormholeNewWidgetStateIdentifier"
    
    static let finishedAutoSyncCountKey = "finishedAutoSyncCount"
    static let totalAutoSyncCountKey = "totalAutoSyncCount"
    static let lastSyncDateKey = "lastSyncDate"
    static let syncStatusKey = "syncStatus"
    static let currentImageDataKey = "currentImageData"
    static let autoSyncEnabledKey = "autoSyncEnabledKey"
    
    static let wormholeLogout = "wormholeLogout"
    static let wormholeDidLogout = "wormholeDidLogout"
    static let wormholeOffTurkcellPassword = "wormholeOffTurkcellPassword"
    
    static let mainAppSchemeResponsivenessDateKey = "mainAppSchemeResponsivenessDateKey"
    static let applicationQueriesSchemeShort = "akillidepo"
    static let applicationQueriesScheme = applicationQueriesSchemeShort + "://"
    
    static let sharedGroupDBContainerName = "SharedGroupDBContainer"
    static let sharedGroupDBName = "SharedGroupDB"
    
    static let lastWidgetEntryKey = "lastWidgetEntry"
    static let lastWidgetEntryTypeKey = "lastWidgetEntryType"
    
    static let isPreparationFinished = "isPreparationFinished"
    static let entryChangedKey = "entryChangedKey"
}
