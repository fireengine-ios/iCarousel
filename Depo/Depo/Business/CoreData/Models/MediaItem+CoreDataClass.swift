//
//  MediaItem+CoreDataClass.swift
//  
//
//  Created by Alexander Gurin on 8/23/17.
//
//

import Foundation
import CoreData
import SwiftyJSON

//enum StatusAction {
//    
//    case waitingUpload
//    
//    case waitingDelete
//    
//    case waitingSync
//}

public class MediaItem: NSManagedObject {
    
    static let Identifier = "MediaItem"
    
    convenience init(wrapData: WrapData, context: NSManagedObjectContext) {
        
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        idValue = wrapData.id ?? -1

        nameValue = wrapData.name

        let char: Character = nameValue?.first ?? " "
        
        fileNameFirstChar = String(describing: char).uppercased()
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.creationDate as NSDate?
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        urlToFileValue = wrapData.urlToFile?.absoluteString
        
        isFolder = wrapData.isFolder ?? false
        
        parent = wrapData.parent
        
        switch wrapData.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue =  url?.absoluteString
        case let .localMediaContent(assetContent):
            localFileID = assetContent.asset.localIdentifier
            patchToPreviewValue = nil
        }
        
        uuidValue = wrapData.uuid
        md5Value = wrapData.md5
        
        let dateValue = self.creationDateValue as Date?
        
        monthValue = dateValue?.getDateForSortingOfCollectionView()
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData
        
        //LR-2356
        let albums = wrapData.albums?.map({ (albumUuid) -> MediaItemsAlbum in
            MediaItemsAlbum(uuid: albumUuid, context: context)
        })
        self.albums = NSOrderedSet(array: albums ?? [])
        
        objectSyncStatus = NSSet(array: wrapData.syncStatuses)
    }
    
    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
}
