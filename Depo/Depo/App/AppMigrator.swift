//
//  AppMigrator.swift
//  Depo
//
//  Created by Oleg on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SQLite

final class AppMigrator {
    
    /// call migrate after Keychain clear
    static func migrateAll() {
        migrateTokens()
        migratePasscode()
        migratePasscodeTouchID()
    }
    
    static func migrateTokens() {
        guard let token = UserDefaults.standard.object(forKey: "REMEMBER_ME_TOKEN_KEY") as? String, !token.isEmpty else {
            return
        }
        
        log.debug("migrateTokens")
        
        let tokenStorage: TokenStorage = factory.resolve()
        tokenStorage.refreshToken = token
        tokenStorage.isRememberMe = true
        
        if tokenStorage.accessToken == nil {
            tokenStorage.accessToken = "" /// need not nil to get new token
        }
    }
    
    static func migratePasscode() {
        guard let passcodeMD5 = UserDefaults.standard.string(forKey: "ApplicationPasscode"), !passcodeMD5.isEmpty else {
            return
        }
        
        log.debug("migratePasscode")
        
        let passcodeStorage: PasscodeStorage = factory.resolve()
        passcodeStorage.save(passcode: passcodeMD5)
    }
    
    static func migratePasscodeTouchID() {
        let passcodeSetting = UserDefaults.standard.integer(forKey: "PassCodeSetting")
        let passcodeSettingOnWithTouchID = 2
        
        log.debug("migratePasscodeTouchID")
        
        if passcodeSetting == passcodeSettingOnWithTouchID {
            var biometricsManager: BiometricsManager = factory.resolve()
            biometricsManager.isEnabled = true
        }
    }
}


//MARK: - Items sync status migration

extension AppMigrator {
    static func migrateSyncStatus(for wrapData: WrapData) {
        guard let fileExtension = wrapData.name?.components(separatedBy: ".").last?.uppercased() else {
            return
        }
        
        let deprecatedUrl = String(format: "assets-library://asset/asset.%@?id=%@&ext=%@", fileExtension, wrapData.getTrimmedLocalID(), fileExtension)
        let deprecatedMD5 = oldMD5(from: deprecatedUrl)
        let isInUserDefaultsHashes = (syncedLocalsHash.contains(deprecatedMD5) || syncedRemotesHash.contains(deprecatedMD5))
        let metaSummary = MetaFileSummary(with: wrapData.name, bytes: wrapData.fileSize)
        let isInDBHashes = syncedFromDB.contains(metaSummary)
        
        let isSynced = isInUserDefaultsHashes || isInDBHashes
        
        if isSynced {
            wrapData.setSyncStatusesAsSyncedForCurrentUser()
        }
        debugPrint("\(wrapData.name) isSynced = \(isSynced) in UD: \(isInUserDefaultsHashes), in BD: \(isInDBHashes)")
    }
    
    private static func oldMD5(from deprecatedUrl: String) -> String {
        guard let md5 = MD5(string: deprecatedUrl) else {
            return ""
        }

        return md5.hex.uppercased()
    }
    
    private static let syncedRemotesHash: Set<String> = {
        let syncedRemoteHashesKey = "SYNCED_REMOTE_HASHES_KEY_AUTH_\(SingletonStorage.shared.uniqueUserID)"
        guard let oldSyncedHashes = UserDefaults.standard.data(forKey: syncedRemoteHashesKey),
            let unarchivedOldSyncedHashes = NSKeyedUnarchiver.unarchiveObject(with: oldSyncedHashes) as? Array<String>
        else {
            return []
        }
        
        return Set(unarchivedOldSyncedHashes)
    }()
    
    private static let syncedLocalsHash: Set<String> = {
        let syncedLocalHashesKey = "SYNCED_LOCAL_HASHES_KEY_AUTH_\(SingletonStorage.shared.uniqueUserID)"
        guard let oldSyncedHashes = UserDefaults.standard.data(forKey: syncedLocalHashesKey),
            let unarchivedOldSyncedHashes = NSKeyedUnarchiver.unarchiveObject(with: oldSyncedHashes) as? Array<String>
            else {
                return []
        }
        
        return Set(unarchivedOldSyncedHashes)
    }()
    
//    private static let removedItemsDBConnection: Connection? = {
//        do {
//            let path = Device.documentsFolderUrl(withComponent: "spmodel.db").path
//            debugPrint("DB PATH FOR REMOVED: \(path)")
//            let db = try Connection(path, readonly: true)
//            return db
//        } catch {
//            return nil
//        }
//    }()
    
    private static let syncedItemsDBConnection: Connection? = {
        let syncDBName = "sync_AUTH_\(SingletonStorage.shared.uniqueUserID).db"
        guard let path = Device.sharedContainerUrl(withComponent: syncDBName)?.path else {
            return nil
        }
        
        do {
            debugPrint("DB PATH FOR SYNCED: \(path)")
            let db = try Connection(path, readonly: true)
            return db
        } catch {
            return nil
        }
    }()
    
//    private static let removedSyncedFromDB: Set<DeletedFileDataModel> = {
//        guard let connection = removedItemsDBConnection else {
//            return []
//        }
//
//        let deletedItems = Table("DeletedFileDataModel")
//
//        do {
//            var allItems = Array<DeletedFileDataModel>()
//            for item in try connection.prepare(deletedItems) {
//                let meta = DeletedFileDataModel(with: item[DeletedFileDataModel.name],
//                                                bytes: item[DeletedFileDataModel.bytes],
//                                                hash: item[DeletedFileDataModel.hash])
//                allItems.append(meta)
//            }
//            return Set(allItems)
//        } catch {
//            return []
//        }
//    }()
    
    private static let syncedFromDB: Set<MetaFileSummary> = {
        guard let connection = syncedItemsDBConnection else {
            return []
        }

        let syncedItems = Table("HashSum")
        do {
            var allSummaries = Array<MetaFileSummary>()
             for item in try connection.prepare(syncedItems) {
                let meta = MetaFileSummary(with: item[MetaFileSummary.name], bytes: item[MetaFileSummary.bytes])
                allSummaries.append(meta)
            }
            return Set(allSummaries)
        } catch {
            return []
        }
    }()
    
    
}


final private class MetaFileSummary: Hashable {
    var hashValue: Int {
        return fileName?.hashValue ?? 0
    }
    
    static func == (lhs: MetaFileSummary, rhs: MetaFileSummary) -> Bool {
        return lhs.fileName == rhs.fileName && lhs.fileSize == rhs.fileSize
    }
    
    var fileSize: Int64?
    var fileName: String?
    
    static let name = Expression<String?>("fileName")
    static let bytes = Expression<Int64?>("bytes")
    
    
    init(with name: String?, bytes: Int64?) {
        fileName = name
        fileSize = bytes
    }
}


//final private class DeletedFileDataModel: Hashable {
//    var hashValue: Int {
//        return fileHash?.hashValue ?? 0
//    }
//
//    static func == (lhs: DeletedFileDataModel, rhs: DeletedFileDataModel) -> Bool {
//        return lhs.fileHash == rhs.fileHash
//    }
//
//    var fileHash: String?
//    var fileSize: Int64?
//    var fileName: String?
//
//    static let hash = Expression<String?>("hash")
//    static let bytes = Expression<Int64?>("bytes")
//    static let name = Expression<String?>("fileName")
//
//
//    init(with name: String?, bytes: Int64?, hash: String?) {
//        fileHash = name
//        fileSize = bytes
//        fileName = name
//    }
//}
