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
    
    var name: String? = nil
    
    var creationDate: Date? = nil
    
    var lastModifiDate: Date? = nil
    
    var fileType: FileType = .application(.unknown)
    
    var syncStatus: SyncWrapperedStatus = .notSynced
    
    var syncStatuses = [String]()
    
    var isLocalItem: Bool
    
    var md5: String = ""
    
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
    
    override var hashValue: Int {
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
    
    func isSynced() -> Bool {
        return syncStatuses.contains(SingletonStorage.shared.unigueUserID)
    }
    
}
