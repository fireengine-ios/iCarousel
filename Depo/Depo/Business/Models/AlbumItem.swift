//
//  AlbumItem.swift
//  Depo
//
//  Created by Oleg on 22.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class AlbumItem: BaseDataSourceItem {
    
    let imageCount: Int?
    
    let videoCount: Int?
    
    let audioCount: Int?
    
    var preview: Item?
    
    let readOnly: Bool?
    
    init (remote: AlbumServiceResponse, previewIconSize: PreviewIconSize = .medium) {

        imageCount = remote.imageCount
        videoCount = remote.videoCount
        audioCount = remote.audioCount
        readOnly = remote.readOnly
        
        if let pr = remote.coverPhoto{
            preview = WrapData(remote: pr)
        }
        
        super.init()
        uuid = remote.uuid ?? UUID().description
        name = remote.name
        creationDate = remote.createdDate
        lastModifiDate = remote.lastModifiedDate
        fileType = FileType(type: remote.contentType, fileName: name)
        syncStatus = .synced
        isLocalItem = false
    }
    
    override func getCellReUseID() -> String {
        return CollectionViewCellsIdsConstant.albumCell
    }
    
}
