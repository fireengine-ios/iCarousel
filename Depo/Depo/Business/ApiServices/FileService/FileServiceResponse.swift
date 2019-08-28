//
//  FilesListResponse.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import SwiftyJSON

class FileListResponse: ObjectRequestResponse {
    
    var parentFolderName: String?
    var parentFolderList = [ParentFolderList]()
    var fileList = [WrapData]()
    
    struct ParentFolderList {
        let id: Int64?
        let name: String?
        let uuid: String?
        let contentType: String?
        let folder: Bool?
        
        init(json: JSON?) {
            id = json?[SearchJsonKey.id].int64
            name = json?[SearchJsonKey.name].string
            uuid = json?[SearchJsonKey.uuid].string
            contentType = json?[SearchJsonKey.content_type].string
            folder = json?[SearchJsonKey.folder].bool
        }
    }
    
    override func mapping() {
        parentFolderName = json?["parentFolderName"].string
        let parentFolderListJson: [JSON]? = json?["parentFolderList"].array
        if let unwrapedParentFolderListJson = parentFolderListJson {
            parentFolderList = unwrapedParentFolderListJson.flatMap { ParentFolderList(json: $0) }
        }
        
        guard let list = json?["fileList"].array else {
            return
        }
        fileList = list.flatMap { WrapData(remote: SearchItemResponse(withJSON: $0),
                                          parendfolderUUID: parentFolderList.first?.uuid) }
//        CoreDataStack.shared.appendOnlyNewItems(items: fileList)
    }
    
}
