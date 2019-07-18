//
//  BaseDataSourceItem.swift
//  Depo
//
//  Created by Oleg on 22.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseDataSourceItem: NSObject {

    var uuid: String
    
    var name: String?
    
    var creationDate: Date?
    
    var lastModifiDate: Date?
    
    var fileType: FileType = .application(.unknown)
    
    var syncStatus: SyncWrapperedStatus = .notSynced
    
    var syncStatuses = [String]()
    
    var isLocalItem: Bool
    
    var md5: String = ""
    
    var parent: String?
    
    func getCellReUseID() -> String {
        return CollectionViewCellsIdsConstant.cellForImage
    }
    
    init(uuid: String? = nil,
         name: String? = nil,
         creationDate: Date? = nil,
         lastModifiDate: Date? = nil,
         fileType: FileType = .application(.unknown),
         syncStatus: SyncWrapperedStatus = .notSynced,
         isLocalItem: Bool = true ) {
        
        self.uuid = uuid ?? UUID().uuidString
        self.name = name
        self.creationDate = creationDate
        self.lastModifiDate = lastModifiDate
        self.fileType = fileType
        self.syncStatus = syncStatus
        self.isLocalItem = isLocalItem
        //super.init()
    }
    
    override var hash: Int {
        if isLocalItem {
            return name!.hashValue
        } else {
            if md5.count == 0 {
                return uuid.hashValue
            } else {
                return md5.hashValue
            }
        }
    }
    
    static func == (left: BaseDataSourceItem, right: BaseDataSourceItem) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? BaseDataSourceItem {
            if isLocalItem != obj.isLocalItem {
                return false
            } else if !isLocalItem {
                return uuid == obj.uuid
            } else if let selfObj = self as? WrapData, let comparableObject = object as? WrapData {
                return selfObj.asset?.localIdentifier == comparableObject.asset?.localIdentifier
            }
        }
        return false
    }
    
    func getUUIDAsLocal() -> String {
        if uuid.contains("~") {
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    func isSynced() -> Bool {
        return syncStatuses.contains(SingletonStorage.shared.uniqueUserID)
    }
    
    func setSyncStatusesAsSyncedForCurrentUser() {
        let userId = SingletonStorage.shared.uniqueUserID
        if !self.syncStatuses.contains(userId) {
            self.syncStatuses.append(userId)
        }
    }
    
}
