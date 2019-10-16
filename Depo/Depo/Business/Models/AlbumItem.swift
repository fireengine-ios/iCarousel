//
//  AlbumItem.swift
//  Depo
//
//  Created by Oleg on 22.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class AlbumItem: BaseDataSourceItem {
    
    var imageCount: Int?
    let videoCount: Int?
    let audioCount: Int?
    var preview: Item?
    let readOnly: Bool?
    var icon: String?
    
    var allContentCount: Int {
        return (imageCount ?? 0) + (videoCount ?? 0) + (audioCount ?? 0)
    }
    
    init (remote: AlbumServiceResponse, previewIconSize: PreviewIconSize = .medium) {

        imageCount = remote.imageCount
        videoCount = remote.videoCount
        audioCount = remote.audioCount
        readOnly = remote.readOnly
        icon = remote.icon
        
        if let pr = remote.coverPhoto {
            preview = WrapData(remote: pr)
        }
        
        super.init()
        uuid = remote.uuid ?? UUID().uuidString
        name = remote.name
        creationDate = remote.createdDate
        lastModifiDate = remote.lastModifiedDate
        fileType = FileType(type: remote.contentType, fileName: name)
        syncStatus = .synced
        setSyncStatusesAsSyncedForCurrentUser()
        isLocalItem = false
    }
    
    override init(uuid: String?, name: String?, creationDate: Date?, lastModifiDate: Date?, fileType: FileType, syncStatus: SyncWrapperedStatus, isLocalItem: Bool) {
        imageCount = 0
        videoCount = 0
        audioCount = 0
        preview = nil
        readOnly = false
        super.init(uuid: uuid, name: name, creationDate: creationDate, lastModifiDate: lastModifiDate, fileType: fileType, syncStatus: syncStatus, isLocalItem: isLocalItem)
    }
    
    override func getCellReUseID() -> String {
        return CollectionViewCellsIdsConstant.albumCell
    }
    
}
