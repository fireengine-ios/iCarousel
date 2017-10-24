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
    
    convenience init(wrapData: WrapData, context:NSManagedObjectContext) {
        
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        idValue = wrapData.id ?? -1
        
        if (wrapData.name == nil) || (wrapData.name?.count == 0){
            nameValue = " ".uppercased()
        }else{
            nameValue = wrapData.name
        }

        let char: Character = (nameValue!).characters.first ?? " "
        
        fileNameFirstChar = String(describing: char).uppercased()
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.creationDate as NSDate?
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        urlToFileValue = wrapData.urlToFile?.absoluteString
        
        switch wrapData.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue =  url?.absoluteString
            isLocalItemValue = false
        case let .localMediaContent(assetContent):
            localFileID = assetContent.asset.localIdentifier
            patchToPreviewValue = nil
            isLocalItemValue = true
        }
        
//        var duration: Double = 0
//        if let durSr = wrapData.duration,
//            let dur = Double(durSr){
//            duration = dur
//        }
//        durationValue = duration
        
        uuidValue = wrapData.uuid
        md5Value = wrapData.md5
        
        let dateValue = self.creationDateValue as Date?
        let textValue = dateValue?.getDateForSortingOfCollectionView()
        monthValue = textValue
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData
        
//        self.albums = wrapData
//        isUploading
//        PHAsset

    }
    
    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
}
