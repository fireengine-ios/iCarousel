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

public class MediaItem: NSManagedObject {
    
    static let Identifier = "MediaItem"
    
    convenience init(json: JSON, context: NSManagedObjectContext) {
///Fields that not filled
//        @NSManaged public var localFileID: String?
//        @NSManaged public var relatedLocal: MediaItem?
//        @NSManaged public var relatedRemotes: NSSet
//        @NSManaged public var session: Session?

        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context) ?? NSEntityDescription()
        self.init(entity: entityDescr, insertInto: context)
//        let fileUUID = json[SearchJsonKey.uuid].string ?? ""
        let metaData = BaseMetaData(withJSON: json[SearchJsonKey.metadata])
        fileSizeValue = json[SearchJsonKey.bytes].int64 ?? 0
        favoritesValue = metaData.favourite ?? false
        trimmedLocalFileID = getRemoteTrimmedID(json: json)
        isICloud = false
        ///Currently we use creation date Value as sorting value, for remotes its takenDate.
        creationDateValue = metaData.takenDate as NSDate? //= json[SearchJsonKey.createdDate].date
        monthValue = metaData.takenDate?.getDateForSortingOfCollectionView()
        lastModifiDateValue = json[SearchJsonKey.lastModifiedDate].date as NSDate?
        idValue = json[SearchJsonKey.id].int64 ?? 0
        nameValue = json[SearchJsonKey.name].string
        fileTypeValue = FileType(type: json[SearchJsonKey.content_type].string,
                                 fileName: nameValue).valueForCoreDataMapping()
        metadata = MediaItemsMetaData(metadata: metaData,///TODO: change to json init
            context: context)
        isFolder = json[SearchJsonKey.folder].bool ?? false
        parent = json[SearchJsonKey.parent].string
        urlToFileValue = json[SearchJsonKey.tempDownloadURL].url?.absoluteString
        albums = NSOrderedSet(array: json[SearchJsonKey.album].array?.flatMap { $0.string } ?? [])
        isLocalItemValue = false
        syncStatusValue = SyncWrapperedStatus.synced.valueForCoreDataMapping()
        objectSyncStatus = convertToMediaItems(syncStatuses: [SingletonStorage.shared.uniqueUserID], context: context)
        patchToPreviewValue = metaData.mediumUrl?.absoluteString
        //            md5Value = (nameValue ?? "") + "\(fileSizeValue)"
        if let fileName = nameValue {
            md5Value = "\(fileName.removeAllPreFileExtentionBracketValues())\(fileSizeValue)"
        }
    }
    
    convenience init(wrapData: WrapData, context: NSManagedObjectContext) {
        
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        idValue = wrapData.id ?? -1

        nameValue = wrapData.name
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.metaDate as NSDate?//wrapData.creationDate as NSDate?
        ///need to discuss that, we might use creation date after all.
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        urlToFileValue = wrapData.urlToFile?.absoluteString
        
        isFolder = wrapData.isFolder ?? false
        
        parent = wrapData.parent
        
        switch wrapData.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue = url?.absoluteString
        case let .localMediaContent(assetContent):
            let localID = assetContent.asset.localIdentifier
            localFileID = localID
            patchToPreviewValue = nil
        }
        
        md5Value = wrapData.md5
        trimmedLocalFileID = wrapData.getTrimmedLocalID()
        
        if isLocalItemValue {
            ///This staus setup only works when all remotes added beforehand
            let relatedTothisItemsRemotes = getAllRelatedItems(wrapItem: wrapData, findRelatedLocals: !isLocalItemValue, context: context)
            relatedRemotes = NSSet(array: relatedTothisItemsRemotes)
            updateLocalRelated(remotesMediaItems: relatedTothisItemsRemotes)
        }
            //TODO:CODE BELOW NEED TO BE TESTED
        else {
            let relatedTothisItemsLocals = getAllRelatedItems(wrapItem: wrapData, findRelatedLocals: isLocalItemValue, context: context)
            relatedLocal = relatedTothisItemsLocals.first
            updateRemoteRelated(localMediaItems: relatedTothisItemsLocals)
        }
        
        if !isLocalItemValue, let md5 = md5Value, let trimmedID = trimmedLocalFileID,
            (md5.isEmpty || trimmedID.isEmpty) {
            debugPrint("!!! REMOTE ITEM MD5 EMPY \(md5Value) AND LOCAL ID \(trimmedLocalFileID)")
        }
        
        let dateValue = self.creationDateValue as Date?
        
        monthValue = dateValue?.getDateForSortingOfCollectionView()
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData
        
        //LR-2356
        let albums = wrapData.albums?.map({ albumUuid -> MediaItemsAlbum in
            MediaItemsAlbum(uuid: albumUuid, context: context)
        })
        self.albums = NSOrderedSet(array: albums ?? [])

        let syncStatuses = convertToMediaItems(syncStatuses: wrapData.syncStatuses, context: context)
        
        objectSyncStatus = syncStatuses
    }
    
    private func getRemoteTrimmedID(json: JSON) -> String  {
        let uuid = json[SearchJsonKey.uuid].stringValue
        if uuid.contains("~"){
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    private func convertToMediaItems(syncStatuses: [String], context: NSManagedObjectContext) -> NSSet {
        return  NSSet(array: syncStatuses.flatMap { MediaItemsObjectSyncStatus(userID: $0, context: context) })
    }

    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
    
    func wrapedObject(with asset: PHAsset) -> WrapData {
        return WrapData(mediaItem: self, asset: asset)
    }
}

//MARK: - relations
extension MediaItem {
    ///This staus setup only works when all remotes added beforehand
//    private func getAllRelatedRemotes(wrapItem: WrapData, context: NSManagedObjectContext) -> [MediaItem] {
//        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
//        request.predicate = getRelatedPredicate(item: wrapItem, locals: false)// NSPredicate(format: "isLocalItemValue == FALSE AND (trimmedLocalFileID == %@ OR md5Value == %@)", wrapItem.getTrimmedLocalID(), wrapItem.md5)
//        let relatedRemotes = try? context.fetch(request)
//        return relatedRemotes ?? []
//    }

    private func getRelatedPredicate(item: WrapData, findRelatedLocals: Bool) -> NSPredicate {
        return NSPredicate(format: "isLocalItemValue == \(findRelatedLocals) AND (trimmedLocalFileID == %@ OR md5Value == %@)", item.getTrimmedLocalID())
    }
    
    func getAllRelatedItems(wrapItem: WrapData, findRelatedLocals: Bool, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, findRelatedLocals: findRelatedLocals)
        let relatedLocals = try? context.fetch(request)
        return relatedLocals ?? []
    }
    
    private func updateLocalRelated(remotesMediaItems: [MediaItem]) {
        remotesMediaItems.forEach {
            $0.relatedLocal = self
        }
    }
    
    private func updateRemoteRelated(localMediaItems: [MediaItem]) {
        localMediaItems.forEach {
            $0.relatedRemotes.adding(self)
        }
    }
}
