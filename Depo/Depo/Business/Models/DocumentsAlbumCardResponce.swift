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
        static let id = "id"
        static let code = "code"
        static let demo = "demo"
        static let name = "name"
        static let thumbnail = "thumbnail"
        static let createdDate = "createdDate"
        static let fileList = "fileList"
        static let albumUuid = "albumUuid"
        static let size = "size"
        static let objectInfo = "objectInfo"
    }
    
    let id: Int
    let code: String
    let demo: Bool
    let name: String
    let thumbnail: String
    let creationDate: Date?
    let albumUuid: String
    let size: Int
    
    init(id: Int, code: String, demo: Bool, name: String, thumbnail: String, creationDate: Date?, size: Int, albumUuid: String) {
        self.id = id
        self.code = code
        self.demo = demo
        self.name =  name
        self.thumbnail = thumbnail
        self.creationDate = creationDate
        self.size = size
        self.albumUuid = albumUuid
    }
    
    convenience init?(json: JSON) {
        print(json)
        
        let objectInfo = json[ResponseKey.objectInfo]
        
        guard
            let id = objectInfo[ResponseKey.id].int,
            let code = objectInfo[ResponseKey.code].string,
            let demo = objectInfo[ResponseKey.demo].bool,
            let name = objectInfo[ResponseKey.name].string,
            let thumbnail = objectInfo[ResponseKey.thumbnail].string,
            
            let albumUuid = json[ResponseKey.albumUuid].string,
            let size = json[ResponseKey.size].int
        else {
            assertionFailure()
            return nil
        }
        
        let creationDate = json[ResponseKey.createdDate].date
        
        self.init(id: id, code: code, demo: demo, name: name, thumbnail: thumbnail, creationDate: creationDate, size: size, albumUuid: albumUuid)
    }
}

