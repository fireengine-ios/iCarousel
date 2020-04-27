//
//  DocumentsAlbumCardResponce.swift
//  Depo
//
//  Created by Maxim Soldatov on 4/20/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON


final class DocumentsAlbumCardResponce {
    
    private enum ResponseKey {
        static let createdDate = "createdDate"
        static let albumUuid = "albumUuid"
        static let size = "size"
        static let objectInfo = "objectInfo"
    }
    
    let thingsItem: ThingsItemResponse
    let creationDate: Date?
    let albumUuid: String
    let size: Int
    
    init(thingsItem: ThingsItemResponse, creationDate: Date?, size: Int, albumUuid: String) {
        self.thingsItem = thingsItem
        self.creationDate = creationDate
        self.size = size
        self.albumUuid = albumUuid
    }
    
    convenience init?(json: JSON) {
        print(json)
        
        let objectInfo = json[ResponseKey.objectInfo]
        
        guard
            let albumUuid = json[ResponseKey.albumUuid].string,
            let size = json[ResponseKey.size].int
        else {
            assertionFailure()
            return nil
        }
        
        let thingsItem = ThingsItemResponse(withJSON: objectInfo)
        let creationDate = json[ResponseKey.createdDate].date
        
        self.init(thingsItem: thingsItem, creationDate: creationDate, size: size, albumUuid: albumUuid)
    }
}

