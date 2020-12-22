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
    
    convenience init(wrapData: WrapData, context: NSManagedObjectContext) {
        
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        idValue = wrapData.id ?? -1
        
        uuid = wrapData.uuid

        nameValue = wrapData.name
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.creationDate as NSDate?
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        if isLocalItemValue {
            sortingDate = wrapData.creationDate as NSDate?
        } else {
            sortingDate = wrapData.metaData?.takenDate as NSDate?
        }
       
        urlToFileValue = wrapData.urlToFile?.absoluteString
        
        isFolder = wrapData.isFolder ?? false
        isTranscoded = wrapData.status.isTranscoded
        status = wrapData.status.valueForCoreDataMapping()
        
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
        
        if !isLocalItemValue, let md5 = md5Value, let trimmedID = trimmedLocalFileID,
            (md5.isEmpty || trimmedID.isEmpty) {
            debugPrint("!!! REMOTE ITEM MD5 EMPTY \(md5Value) AND LOCAL ID \(trimmedLocalFileID)")
        }
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData

        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        
        let syncStatuses = convertToMediaItems(syncStatuses: wrapData.syncStatuses, context: context)
        objectSyncStatus = syncStatuses
        
        if isLocalItemValue {
            let savedRelatedRemotes = getRelatedRemotes(for: wrapData, context: context)
            if !savedRelatedRemotes.isEmpty {
                addToObjectSyncStatus(MediaItemsObjectSyncStatus(userID: SingletonStorage.shared.uniqueUserID, context: context))
                savedRelatedRemotes.forEach { $0.localFileID = localFileID }
                relatedRemotes = NSSet(array: savedRelatedRemotes)
                updateLocalRelated(remotesMediaItems: savedRelatedRemotes)
            }
        } else {
            let savedRelatedLocals = getRelatedLocals(for: wrapData, context: context)
            if !savedRelatedLocals.isEmpty {
                savedRelatedLocals.forEach {
                    $0.addToObjectSyncStatus(MediaItemsObjectSyncStatus(userID: SingletonStorage.shared.uniqueUserID, context: context))
                }
                relatedLocal = savedRelatedLocals.first
                localFileID = relatedLocal?.localFileID
                updateRemoteRelated(localMediaItems: savedRelatedLocals)
            }
        }
        
        updateRelatedLocalAlbums(context: context)
        updateAvalability()
        
        //empty monthValue for missing dates section
//        switch wrapData.patchToPreview {
//        case .remoteUrl(let url):
//            if url != nil || localFileID != nil {
//                fallthrough
//            }
//        default:
            monthValue = (sortingDate as Date?)?.getDateForSortingOfCollectionView()
//        }
        
        updateMissingDateRelations()
    }
    
    private func getRemoteTrimmedID(json: JSON) -> String  {
        let uuid = json[SearchJsonKey.uuid].stringValue
        if uuid.contains("~"){
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    private func convertToMediaItems(syncStatuses: [String], context: NSManagedObjectContext) -> NSSet {
        return NSSet(array: syncStatuses.compactMap { MediaItemsObjectSyncStatus(userID: $0, context: context) })
    }

    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
    
    func wrapedObject(with asset: PHAsset) -> WrapData {
        return WrapData(mediaItem: self, asset: asset)
    }
    
    func copyInfo(item: WrapData, context: NSManagedObjectContext) {
        ///FOR NOW we copy everything, could downgrated to just urls and name
        
        metadata?.copyInfo(metaData: item.metaData)
        
        creationDateValue = item.creationDate as NSDate?
        lastModifiDateValue = item.lastModifiDate as NSDate?
        sortingDate = (item.metaData?.takenDate ?? item.creationDate) as NSDate?
        
        urlToFileValue = item.tmpDownloadUrl?.absoluteString
        
        switch item.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue = url?.absoluteString
        case let .localMediaContent(assetContent):
            let localID = assetContent.asset.localIdentifier
            localFileID = localID
            patchToPreviewValue = nil
        }
        
        trimmedLocalFileID = item.getTrimmedLocalID()
        parent = item.parent
        md5Value = item.md5
        isFolder = item.isFolder ?? false
        favoritesValue = item.favorites
        fileTypeValue = item.fileType.valueForCoreDataMapping()
        fileSizeValue = item.fileSize
        nameValue = item.name
        idValue = item.id ?? -1
        uuid = item.uuid
        
        //empty monthValue for missing dates section
        switch item.patchToPreview {
        case .remoteUrl(let url):
            if url != nil || localFileID != nil {
                fallthrough
            }
        default:
            monthValue = (sortingDate as Date?)?.getDateForSortingOfCollectionView()
        }
        
        
        //
        self.albums?.forEach { album in
            if let savedAlbum = album as? MediaItemsAlbum {
                context.delete(savedAlbum)
            }
        }

        isTranscoded = item.status.isTranscoded
        status = item.status.valueForCoreDataMapping()
        updateMissingDateRelations()
    }
    
    func updateMissingDateRelations() {
        guard isLocalItemValue else {
            relatedLocal?.updateMissingDateRelations()
            return
        }
        
        if let relatedRemotes = relatedRemotes as? Set<MediaItem>, !relatedRemotes.isEmpty {
            hasMissingDateRemotes = relatedRemotes.filter { $0.monthValue == nil }.count == relatedRemotes.count
        } else {
            hasMissingDateRemotes = false
        }
    }
    
    func getFisrtUUIDPart() -> String? {
        guard let uuid = uuid else {
            assertionFailure()
            return nil
        }
        
        if uuid.contains("~") {
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }

    func regenerateTrimmedLocalFileID() {
        guard let localFileID = localFileID?.components(separatedBy: "/").first, localFileID != trimmedLocalFileID else {
            return
        }
        
        if trimmedLocalFileID?.contains("~") == true, let secondPart = trimmedLocalFileID?.split(separator: "~").last {
            trimmedLocalFileID = localFileID + "~" + secondPart
            return
        }
        
        trimmedLocalFileID = localFileID
    }
    
    private func isThumbnailMissing() -> Bool {
        return metadata?.smalURl == nil && metadata?.mediumUrl == nil
    }
    
    func moveToMissingDatesIfNeeded() {
        if isThumbnailMissing() {
            sortingDate = nil
        }
    }
    
    func updateAvalability() {
        guard isLocalItemValue else {
            isAvailable = true
            return
        }
        
        if let localAlbums = localAlbums?.array as? [MediaItemsLocalAlbum] {
            if localAlbums.count == 1 {
                //case for main album
                isAvailable = true
            } else {
                isAvailable = localAlbums.first(where: { $0.isEnabled && !$0.isMain }) != nil
            }
        } else {
            isAvailable = false
        }
    }
}

//MARK: - relations
extension MediaItem {

    private func getRelatedPredicate(item: WrapData, local: Bool) -> NSPredicate {
        return NSPredicate(format: "\(PropertyNameKey.isLocalItemValue) = %@ AND (\(PropertyNameKey.trimmedLocalFileID) = %@ OR \(PropertyNameKey.md5Value) = %@ OR \(PropertyNameKey.localFileID) = %@)", NSNumber(value: local), item.getTrimmedLocalID(), item.md5, item.getLocalID())
    }
    
    func getRelatedLocals(for wrapItem: WrapData, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, local: true)
        let relatedLocals = try? context.fetch(request)
        return relatedLocals ?? []
    }
    
    func getRelatedRemotes(for wrapItem: WrapData, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, local: false)
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
            $0.addToRelatedRemotes(self)
        }
    }
    
    private func updateRelatedLocalAlbums(context: NSManagedObjectContext) {
        guard isLocalItemValue, let localId = localFileID else {
            return
        }
        
        let localAlbumIds = LocalAlbumsCache.shared.albumIds(assetId: localId)
        let request: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.localId) IN %@", localAlbumIds)
        
        if let relatedAlbums = try? context.fetch(request) {
            relatedAlbums.forEach {
                $0.addToItems(self)
                $0.updateHasItems()
            }
        }
    }
}
