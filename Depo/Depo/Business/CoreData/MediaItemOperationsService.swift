//
//  MediaItemOperationsService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Photos

typealias LocalFilesCallBack = (_ localFiles: [WrapData]) -> Void
typealias MediaItemsCallBack = (_ mediaItems: [MediaItem]) -> Void
typealias PhotoAssetsCallback = (_ assets: [PHAsset]) -> Void
typealias AppendingLocaclItemsFinishCallback = () -> Void
typealias AppendingLocaclItemsProgressCallback = (Float) -> Void
typealias AppendingLocalItemsPageAppended = ([Item])->Void

final class MediaItemOperationsService {
    
    static let shared = MediaItemOperationsService()
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemOperationsService, attributes: .concurrent)
    
//    var pageAppendedCallBack: AppendingLocalItemsPageAppended?
    
    var inProcessAppendingLocalFiles = false
    
    var originalAssetsBeingAppended = AssetsCache()
    var nonCloudAlreadySavedAssets = AssetsCache()
    
    func deleteRemoteEntities(_ completion: BoolHandler?) {
        let remoteMediaItemsPredicate = PredicateRules().predicate(filters: [.localStatus(.nonLocal)])
        
        let elementsToDelete: [(type: NSManagedObject.Type, predicate: NSPredicate?)]
        elementsToDelete = [(MediaItemsAlbum.self, nil),
                            (MediaItem.self, remoteMediaItemsPredicate)]
        
        let group = DispatchGroup()
        
        for element in elementsToDelete {
            group.enter()
            
            delete(type: element.type, predicate: element.predicate, mergeChanges: false) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion?(true)
        }
    }
    
    private func delete(type: NSManagedObject.Type, predicate: NSPredicate?, mergeChanges: Bool, _ completion: BoolHandler?) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            do {
                let objectIDs = try [type]
                    .compactMap { $0.entityDescription(context: context)}
                    .compactMap { self.batchDeleteRequest(for: $0, predicate: predicate) }
                    .compactMap { try context.execute($0) as? NSBatchDeleteResult }
                    .compactMap { $0.result as? [NSManagedObjectID] }
                    .flatMap { $0 }
                
                let changes = [NSDeletedObjectsKey: objectIDs]

                if mergeChanges {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context.parent ?? CoreDataStack.default.mainContext])
                }
                completion?(true)
                
            } catch {
                //TODO:
                completion?(false)
            }
        }
    }
    
    func deleteLocalFiles(completion: BoolHandler?) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
            return
        }
        fetchRequest.predicate = predicate
        let context = CoreDataStack.default.newChildBackgroundContext
        self.deleteObjects(fromFetch: fetchRequest, context: context, completion: nil)
        
    }
    
    func getLocalDuplicates(localItems: @escaping MediaItemsCallBack) {
        let context = CoreDataStack.default.newChildBackgroundContext
        let predicate = NSPredicate(format: "isLocalItemValue == true AND relatedRemotes.@count > 0")
        
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: localItems)
    }
    
    func getLocalDuplicates(remoteItems: [Item], duplicatesCallBack: @escaping LocalFilesCallBack) {
        getLocalDuplicates { localItems in
//            self?.privateQueue.async {
                var array = [WrapData]()
                let uuids = Set(remoteItems.map {$0.getTrimmedLocalID()})
                
                for localItem in localItems {
                    autoreleasepool {
                        if let relatedRemotes = localItem.relatedRemotes as? Set<MediaItem> {
                            let relatedUuids = relatedRemotes.compactMap {$0.trimmedLocalFileID}
                            if !uuids.intersection(relatedUuids).isEmpty {
                                array.append(WrapData(mediaItem: localItem))
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    duplicatesCallBack(array)
                }
//            }
        }
    }
    
    //TODO: check the usefullness of it/or need of refactor
    func getLocalFilteredItem(remoteOriginalItem: Item, localFilteredPhotosCallBack: @escaping (Item?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value = %@) AND (isFiltered == true)", remoteOriginalItem.md5, remoteOriginalItem.getTrimmedLocalID())
        
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                localFilteredPhotosCallBack(nil)
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.compactMap { WrapData(mediaItem: $0) }
            localFilteredPhotosCallBack(array.first)
        }
        
    }
    
    private func deleteObjects(fromFetches fetchRequests: [NSFetchRequest<NSFetchRequestResult>], completion: BoolHandler?) {
        let context = CoreDataStack.default.newChildBackgroundContext
        let group = DispatchGroup()
        
        for fetchRequest in fetchRequests {
            group.enter()
            self.deleteObjects(fromFetch: fetchRequest, context:context, completion: { _ in
                group.leave()
            })
        }
        group.notify(queue: .main) {
            completion?(true)
        }
    }
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: BoolHandler?) {
//        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let fetchResult = try? context.fetch(fetchRequest),
                let unwrapedObjects = fetchResult as? [NSManagedObject],
                unwrapedObjects.count > 0
            else {
                completion?(false)
                return
            }
            
            for object in unwrapedObjects {
                context.delete(object)
            }
            CoreDataStack.default.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                completion?(true)
                debugPrint("Data base deleted objects")
            })
            
        }
    }
    
    // MARK: - MediaItemOperations
    
    
    
//    func updateSavedItems(savedItems: [MediaItem], remoteItems: [WrapData], context: NSManagedObjectContext) {
//        guard savedItems.count > 0 else {
//            return
//        }
//        context.perform { [weak self] in
//            for savedMediaItem in savedItems {
//                for remoteWrapedItem in remoteItems {
//                    if savedMediaItem.trimmedLocalFileID == remoteWrapedItem.getTrimmedLocalID() {
//                        if let unwrapedParent = remoteWrapedItem.parent {
//                            savedMediaItem.parent = unwrapedParent
//                        }
//                        if let unwrapedAlbumbs = remoteWrapedItem.albums {
//                            //LR-2356
//                            
//                            let albums = unwrapedAlbumbs.map({ albumUuid -> MediaItemsAlbum in
//                                MediaItemsAlbum(uuid: albumUuid, context: context)
//                            })
//                            
//                            
//                            savedMediaItem.albums = NSOrderedSet(array: albums)
//                        }
//                        savedMediaItem.urlToFileValue = remoteWrapedItem.urlToFile?.absoluteString
//                        savedMediaItem.metadata?.largeUrl = remoteWrapedItem.metaData?.largeUrl?.absoluteString
//                        savedMediaItem.metadata?.mediumUrl = remoteWrapedItem.metaData?.mediumUrl?.absoluteString
//                        savedMediaItem.metadata?.smalURl = remoteWrapedItem.metaData?.smalURl?.absoluteString
//                        savedMediaItem.favoritesValue = remoteWrapedItem.favorites
//                        
//                        savedMediaItem.syncStatusValue = remoteWrapedItem.syncStatus.valueForCoreDataMapping()
//                        
//                        break
//                    }
//                }
//            }
//            
//            CoreDataStack.default.saveDataForContext(context: context, savedCallBack: nil)
//        }
//    }
    //TODO: check the usefullness of it/or need of refactor
    func updateLocalItemSyncStatus(item: Item, newRemote: WrapData? = nil) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            let predicateForRemoteFile = NSPredicate(format: "trimmedLocalFileID == %@ AND isLocalItemValue == true", item.getTrimmedLocalID())
            
            
            self.executeRequest(predicate: predicateForRemoteFile, context: context) { alreadySavedMediaItems in
                alreadySavedMediaItems.forEach({ savedItem in
                    //for locals
                    savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
                    
                    if savedItem.objectSyncStatus != nil {
                        savedItem.objectSyncStatus = nil
                    }
                    
                    var array = [MediaItemsObjectSyncStatus]()
                    for userID in item.syncStatuses {
                        array.append(MediaItemsObjectSyncStatus(userID: userID, context: context))
                    }
                    savedItem.objectSyncStatus = NSSet(array: array)
                    //savedItem.objectSyncStatus?.addingObjects(from: item.syncStatuses)
                })
                if let newRemoteItem = newRemote {
                    //all relation will be setuped inside
                    _ = MediaItem(wrapData: newRemoteItem, context: context)
                }
                context.saveAsync()
            }
        }
    }
    
    func updateRelatedRemoteItems(mediaItem: MediaItem, context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard let uuid = mediaItem.trimmedLocalFileID, let md5 = mediaItem.md5Value else {
            return
        }

        let predicateForRemoteFiles = NSPredicate(format: "(trimmedLocalFileID == %@ OR md5Value == %@) AND isLocalItemValue == false", uuid, md5)
        
        executeRequest(predicate: predicateForRemoteFiles, context: context) { alreadySavedRemoteItems in
            context.performAndWait {
                alreadySavedRemoteItems.forEach({ savedItem in
                    savedItem.relatedLocal = mediaItem
                    mediaItem.addToRelatedRemotes(savedItem)
                })
                completion()
            }
        }
    }
    
    // MARK: MediaItem
    
    func mediaItemByLocalID(trimmedLocalIDS: [String],
                            context: NSManagedObjectContext = CoreDataStack.default.newChildBackgroundContext,
                            mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "trimmedLocalFileID IN %@ AND isLocalItemValue == true", trimmedLocalIDS)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func executeRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.fetchLimit = limit
        request.predicate = predicate
        execute(request: request, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func execute(request: NSFetchRequest<MediaItem>, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        context.perform {
            var result: [MediaItem] = []
            do {
                result = try context.fetch(request)
            } catch {
                print("context.fetch failed with:", error.localizedDescription)
            }
            mediaItemsCallBack(result)
        }
    }
    
    // MARK: - Remote Items
    
    func appendRemoteMediaItems(remoteItems: [Item], completion: @escaping VoidHandler) {
        // OR should we mark sync status and etc here. And also affect free app?

        guard !remoteItems.isEmpty else {
            debugPrint("REMOTE_ITEMS: no files to add")
            completion()
            return
        }
        
        checkRemoteItemsExistence(wrapData: remoteItems) { newItems in
            debugPrint("REMOTE_ITEMS: \(newItems.count) remote files to add")
            
            let context = CoreDataStack.default.newChildBackgroundContext
            context.perform {
                newItems.forEach { item in
                    autoreleasepool {
                        _ = MediaItem(wrapData: item, context: context)
                    }
                }
                CoreDataStack.default.saveDataForContext(context: context, savedCallBack: completion)
            }
            
            //      ItemOperationManager.default.addedLocalFiles(items: addedObjects)
            //WARNING:- DO we need notify ItemOperationManager here???
        }
    }

    func updateRemoteItems(remoteItems: [WrapData], fileType: FileType, topInfo: RangeAPIInfo, bottomInfo: RangeAPIInfo, completion: @escaping VoidHandler) {
        let remoteIds = remoteItems.compactMap { $0.id }
        let context = CoreDataStack.default.newChildBackgroundContext
        
        let inDateRangePredicate = NSPredicate(format:"fileTypeValue = %d AND isLocalItemValue = false AND sortingDate != Nil AND (sortingDate <= %@ AND sortingDate >= %@) AND (idValue <= %ld AND idValue >= %ld)", fileType.valueForCoreDataMapping(), topInfo.date as NSDate, bottomInfo.date as NSDate, topInfo.id ?? Int64.max, bottomInfo.id ?? 0)
        
        executeRequest(predicate: inDateRangePredicate, limit: RequestSizeConstant.quickScrollRangeApiPageSize, context: context) { inDateRangeItems in

            debugPrint("--- remotes in date range count \(remoteItems.count)")
            debugPrint("--- count of already saved in date range \(inDateRangeItems.count)")
            
            let inIdRangePredicate = NSPredicate(format:"fileTypeValue = %d AND isLocalItemValue = false AND (idValue IN %@) AND NOT (idValue IN %@)", fileType.valueForCoreDataMapping(), remoteIds, inDateRangeItems.compactMap { $0.idValue })
            
            self.executeRequest(predicate: inIdRangePredicate, context: context, mediaItemsCallBack: { inIdRangeItems in
                debugPrint("--- count of already saved in id range \(inIdRangeItems.count)")
                
                var allSavedItems = (inDateRangeItems + inIdRangeItems).compactMap { WrapData(mediaItem: $0) }
                debugPrint("--- count of already saved TOTAL count \(allSavedItems.count)")
                
                var deletedItems = [WrapData]()
                var newSavedItems = [WrapData]()
                
                for newItem in remoteItems {
                    if let existed = allSavedItems.first(where: { $0.uuid == newItem.uuid }) {
                        if newItem != existed {
                            existed.coreDataObject?.copyInfo(item: newItem, context: context)
                        }
                        allSavedItems.remove(existed)
                    } else if !allSavedItems.contains(where: {$0.uuid == newItem.uuid }) {
                        newSavedItems.append(newItem)
                        allSavedItems.remove(newItem)
                    }
                }
                deletedItems.append(contentsOf: allSavedItems)
                
                deletedItems.forEach {
                    if let coreDataObject = $0.coreDataObject {
                        context.delete(coreDataObject)
                    }
                }
                
                newSavedItems.forEach {
                    ///Relations being setuped in the MediaItem init
                    _ = MediaItem(wrapData: $0, context: context)
                }
                
                context.saveAsync(completion: { status in
                    completion()
                })
            })
        }
    }
    
    func getAllRemotesMediaItem(allRemotes: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "isLocalItemValue = false")
        executeRequest(predicate: predicate, context: CoreDataStack.default.newChildBackgroundContext, mediaItemsCallBack: allRemotes)
        
    }
    
    func isNoRemotesInDB(result: @escaping (_ noRemotes: Bool) -> Void) {
        let predicate = NSPredicate(format: "isLocalItemValue = false")
        let fetchRequest = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        execute(request: fetchRequest, context: CoreDataStack.default.newChildBackgroundContext) { items in
            result(items.isEmpty)
        }
    }
    
    // MARK: - LocalMediaItems
    
    @objc func appendLocalMediaItems(completion: VoidHandler?) {
        let localMediaStorage = LocalMediaStorage.default
        
        guard !localMediaStorage.isWaitingForPhotoPermission else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] _, status in
            switch status {
            case .denied:
                MediaItemOperationsService.shared.deleteLocalFiles(completion: { _ in
                    completion?()
                })
            case .authorized:
                self?.insertFromGallery(completion: completion)
            case .restricted, .notDetermined:
                break
            }
        }
    }
    
    func append(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        privateQueue.async { [weak self] in
            guard let `self` = self else {
                completion()
                return
            }
            ///check which are new
            var newAssets =  [PHAsset]()
            var assetsToUpdate =  [PHAsset]()
            localMediaItems.forEach {
                if LocalMediaStorage.default.assetsCache.assetBy(identifier: $0.localIdentifier) != nil {
                    //update
                    assetsToUpdate.append($0) ///for now its useless
                } else {
                    newAssets.append($0)
                }
            }
            LocalMediaStorage.default.assetsCache.append(list: newAssets)
            
            self.saveLocalMediaItemsPaged(items: newAssets, context: CoreDataStack.default.newChildBackgroundContext, completion: completion)
        }
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier }, completion: completion)
        
    }
    
    private func insertFromGallery(completion: VoidHandler?) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion?()
            return
        }
        guard !inProcessAppendingLocalFiles else {
            return
        }
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default
        
        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList)
        let context = CoreDataStack.default.newChildBackgroundContext
        listAssetIdIsNotSaved(allList: assetsList, context: context) { [weak self] notSavedAssets in
            let start = Date()
            
            guard !notSavedAssets.isEmpty else {
                self?.inProcessAppendingLocalFiles = false
                print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                completion?()
                return
            }
            
            print("All local files started  \((start)) seconds")
            self?.originalAssetsBeingAppended.append(list: notSavedAssets)///tempo assets
            self?.nonCloudAlreadySavedAssets.dropAll()
            self?.saveLocalMediaItemsPaged(items: notSavedAssets, context: context) { [weak self] in
                self?.originalAssetsBeingAppended.dropAll()///tempo assets
                print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
                self?.inProcessAppendingLocalFiles = false
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                
//                self?.pageAppendedCallBack?([])
                completion?()
            }
        }
    }
    
    private func saveLocalMediaItemsPaged(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        guard !items.isEmpty else {
            print("LOCAL_ITEMS: no files to add")
            completion()
            return
        }
        
        print("LOCAL_ITEMS: \(items.count) local files to add")
        let start = Date()
        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))
        privateQueue.async { [weak self] in
            
            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] info in
                context.perform { [weak self] in
                    var addedObjects = [WrapData]()
                    let assetsInfo = info.filter { $0.isValid }
                    assetsInfo.forEach { element in
                        autoreleasepool {
                            let wrapedItem = WrapData(info: element)
                            _ = MediaItem(wrapData: wrapedItem, context: context)
                            
                            addedObjects.append(wrapedItem)
                        }
                    }
                    
                    CoreDataStack.default.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
//                        self?.pageAppendedCallBack?(addedObjects)
                        
                        ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                        print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
                        self?.saveLocalMediaItemsPaged(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                    })
                    
                    
                }
            })
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            self?.privateQueue.async { [weak self] in
                
                guard let `self` = self else {
                    return
                }
                
                self.listAssetIdAlreadySaved(allList: assets, context: context) { alreadySavedAssets in
                    let start = Date()
                    LocalMediaStorage.default.getCompactInfo(from: alreadySavedAssets, completion: { [weak self] info in
                        guard let `self` = self else {
                            return
                        }
                        print("iCloud: updated iCloud in \(Date().timeIntervalSince(start)) secs")
                        context.perform {
                            let invalidItems = info.filter { !$0.isValid }.map { $0.asset.localIdentifier }
                            print("iCloud: removing \(invalidItems.count) items")
                            self.removeLocalMediaItems(with: invalidItems, completion: {})
                        }
                    })
                }
            }
        }
    }
    
    func listAssetIdAlreadySaved(allList: [PHAsset], context: NSManagedObjectContext, assetCallback: @escaping PhotoAssetsCallback) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            assetCallback([])
            return
        }
        
        let currentlyInLibriaryIDs = allList.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        executeRequest(predicate: predicate, context: context) { alredySaved in
            let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
            
            assetCallback(allList.filter { alredySavedIDs.contains( $0.localIdentifier ) })
        }
        
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext,
                                       callBack: @escaping PhotoAssetsCallback) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callBack([])
            return
        }
        
        let localIdentifiers = allList.map { $0.localIdentifier }
        checkLocalFilesExistence(actualPhotoLibItemsIDs: localIdentifiers)
        let predicate = NSPredicate(format: "localFileID IN %@ AND isLocalItemValue == true", localIdentifiers)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            let alredySavedIDs = mediaItems.compactMap { $0.localFileID }
            callBack(allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) })
        })
    }
    
    func removeLocalMediaItems(with assetIdList: [String], completion: @escaping VoidHandler) {
        guard assetIdList.count > 0 else {
            return
        }
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                completion()
                return
            }
            let predicate = NSPredicate(format: "localFileID IN %@ AND isLocalItemValue == true", assetIdList)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
               
                let deletedItems = mediaItems.map{ WrapData(mediaItem: $0) }
                LocalMediaStorage.default.assetsCache.remove(identifiers: assetIdList)
                ItemOperationManager.default.deleteItems(items: deletedItems)
                mediaItems.forEach { context.delete($0) }
                
                CoreDataStack.default.saveDataForContext(context: context, savedCallBack: { [weak self] in
                    ///Appearantly after recovery local ID may change, so temporary soloution is to check all files all over. and in the future chenge DataBase behavior heavily
                    let assetsList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
                    
                    self?.checkLocalFilesExistence(actualPhotoLibItemsIDs: assetsList.map{$0.localIdentifier}, complition: completion)
                })
                
            }
        }
    }
    
    func deleteItems(_ items: [WrapData], completion: @escaping VoidHandler) {
        guard !items.isEmpty else {
            return
        }
        
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            
            let predicate = NSPredicate(format: "uuid in %@", items.map {$0.uuid} )
            self.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { remoteItems in
                remoteItems.forEach { context.delete($0) }
                
                let remoteItemsSet = NSSet(array: remoteItems)
                
                self.mediaItemByLocalID(trimmedLocalIDS: items.map {$0.getTrimmedLocalID()}, context: context, mediaItemsCallBack: { mediaItems in
                    mediaItems.forEach { $0.removeFromRelatedRemotes(remoteItemsSet)}
                    
                    remoteItems.forEach { context.delete($0) }
                    
                    context.saveAsync(completion: { _ in
                        completion()
                    })
                })
            })
        }
        
        
        
        //        let predicate = NSPredicate(format: "uuid IN %@", items.compactMap { $0.uuid })
        //        delete(type: MediaItem.self, predicate: predicate, mergeChanges: true, { _ in
        //            completion()
        //        })
        
    }
    
    private func batchDeleteRequest(for entityDescription: NSEntityDescription, predicate: NSPredicate?) -> NSBatchDeleteRequest {
        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>()
        deleteFetchRequest.entity = entityDescription
        deleteFetchRequest.predicate = predicate
        deleteFetchRequest.includesPropertyValues = false
        deleteFetchRequest.returnsObjectsAsFaults = false
        deleteFetchRequest.resultType = .managedObjectIDResultType
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        return batchDeleteRequest
    }
    
    func allLocalItems(localItems: @escaping LocalFilesCallBack) {
        let context = CoreDataStack.default.newChildBackgroundContext
        let predicate = NSPredicate(format: "localFileID != nil")
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            localItems(mediaItems.map { $0.wrapedObject })
        })
    }
    
    func localItemsBy(assets: [PHAsset], localItemsCallback: @escaping LocalFilesCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
        let context = CoreDataStack.default.newChildBackgroundContext
       
        let predicate = NSPredicate(format:
        "(\(#keyPath(MediaItem.localFileID)) != nil) AND (\(#keyPath(MediaItem.localFileID)) IN %@) AND \(#keyPath(MediaItem.isLocalItemValue)) == true", assets.map { $0.localIdentifier })
        
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        context.perform {
            guard let result = try? context.fetch(request) else {
                localItemsCallback([])
                return
            }
            var localItems = [WrapData]()
            for (item, asset) in zip(result, assets) {
                localItems.append(item.wrapedObject(with: asset))
            }
            localItemsCallback(localItems)
        }
    }
    
    func allLocalItems(with assets: [PHAsset], localItemsCallback: @escaping LocalFilesCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let context = CoreDataStack.default.newChildBackgroundContext
        
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@) AND isLocalItemValue == true", assets.map { $0.localIdentifier })
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            /// sort items in the assets order
            var items = mediaItems
            let ordering = Dictionary(uniqueKeysWithValues: assets.enumerated().map { ($1.localIdentifier, $0) })
            items = items.sorted(by: { (firstItem, secondItem) -> Bool in
                if let firstLocalId = firstItem.localFileID, let firstIndex = ordering[firstLocalId] {
                    if let secondLocalId = secondItem.localFileID, let secondIndex = ordering[secondLocalId] {
                        return firstIndex < secondIndex
                    } else {
                        return false
                    }
                }
                return false
            })
            
            var localItems = [WrapData]()
            for (item, asset) in zip(items, assets) {
                localItems.append(item.wrapedObject(with: asset))
            }
            
            localItemsCallback(localItems)
        })

    }
    
    func allLocalItems(trimmedLocalIds: [String], localItemsCallBack: @escaping LocalFilesCallBack) {
        let context = CoreDataStack.default.newChildBackgroundContext
        let predicate = NSPredicate(format: "(trimmedLocalFileID != nil) AND (trimmedLocalFileID IN %@ AND isLocalItemValue == true)", trimmedLocalIds)
        executeRequest(predicate: predicate, context: context) { mediaItems in
             localItemsCallBack(mediaItems.map{ $0.wrapedObject })
        }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool, completion: @escaping  (_ has: Bool) -> Void) {
        getUnsyncedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items.map { $0.wrapedObject }
            completion(!AppMigrator.migrateSyncStatus(for: wrappedItems).isEmpty)
        })
        
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping (_ items: [WrapData]) -> Void) {
        getUnsyncedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items
                .filter { $0.fileSizeValue < NumericConstants.fourGigabytes }
                .sorted { $0.fileSizeValue < $1.fileSizeValue }
                .compactMap { $0.wrapedObject }
            
            completion(AppMigrator.migrateSyncStatus(for: wrappedItems))
        })
    }
    
    private func getUnsyncedMediaItems(video: Bool, image: Bool, completion: @escaping MediaItemsCallBack) {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs = assetList.map { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@) AND (SUBQUERY(objectSyncStatus, $x, $x.userID == %@).@count == 0)", filesTypesArray, currentlyInLibriaryLocalIDs, SingletonStorage.shared.uniqueUserID)
            self?.executeRequest(predicate: predicate, context: context) { mediaItems in
                completion(mediaItems)
            }
        }
    }
    
    private func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], complition: VoidHandler? = nil) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@) AND isLocalItemValue == true", actualPhotoLibItemsIDs)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                mediaItems.forEach {
                        context.delete($0)
                }
                CoreDataStack.default.saveDataForContext(context: context, savedCallBack: {
                    /// put notification here that item deleted
                    let items = mediaItems.map { $0.wrapedObject }
                    ItemOperationManager.default.deleteItems(items: items)
                    complition?()
                })
            }
        }
    }
    
    private func checkRemoteItemsExistence(wrapData: [WrapData], completion: @escaping (_ filteredItems: [WrapData])->Void) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "(isLocalItemValue == false) AND (uuid IN %@)", wrapData.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                let existedUUIDS = mediaItems.compactMap { $0.uuid }
                
                completion(wrapData.filter { !existedUUIDS.contains($0.uuid) })
            }
        }
    }
}
