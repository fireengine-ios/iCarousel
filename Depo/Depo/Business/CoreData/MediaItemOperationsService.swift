//
//  MediaItemOperationsService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Photos

typealias WrapObjectsCallBack = (_ items: [WrapData]) -> Void
typealias BaseDataSourceItems = (_ baseDSItems: [BaseDataSourceItem]) -> Void
typealias MediaItemsCallBack = (_ mediaItems: [MediaItem]) -> Void
typealias MediaItemCallback = (_ mediaItem: MediaItem?) -> Void
typealias PhotoAssetsCallback = (_ assets: [PHAsset]) -> Void
typealias AppendingLocaclItemsFinishCallback = () -> Void
typealias AppendingLocaclItemsProgressCallback = (Float) -> Void
typealias AppendingLocalItemsPageAppended = ([Item])->Void

final class MediaItemOperationsService {
    
    static let shared = MediaItemOperationsService()
    
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemOperationsService, attributes: .concurrent)
    
//    var pageAppendedCallBack: AppendingLocalItemsPageAppended?
    
    var inProcessLocalFiles = false
    
    
    func deleteAllEnteties(_ completion: BoolHandler?) {
        let elementsToDelete: [(type: NSManagedObject.Type, predicate: NSPredicate?)]
        elementsToDelete = [(MediaItemsAlbum.self, nil),
                            (MediaItem.self, nil)]
        
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
    
    func deleteRemoteEntities(uuids: [String], completion: BoolHandler?) {
        guard let remoteMediaItemsPredicate = PredicateRules().predicate(filters: [.localStatus(.nonLocal)]) else {
            completion?(false)
            return
        }
        let uuidsPredicate = NSPredicate(format: "\(#keyPath(MediaItem.uuid)) IN %@", uuids)
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [remoteMediaItemsPredicate, uuidsPredicate])
        
        delete(type: MediaItem.self, predicate: compoundedPredicate, mergeChanges: false) { _ in
            completion?(true)
        }
    }
    
    private func delete(type: NSManagedObject.Type, predicate: NSPredicate?, mergeChanges: Bool, _ completion: BoolHandler?) {
        coreDataStack.performBackgroundTask { [weak self] context in
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
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context.parent ?? self.coreDataStack.mainContext])
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
        let context = coreDataStack.newChildBackgroundContext
        self.deleteObjects(fromFetch: fetchRequest, context: context, completion: completion)
        
    }
    
    func getLocalDuplicates(localItems: @escaping MediaItemsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "isLocalItemValue == true AND relatedRemotes.@count > 0")
        
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: localItems)
    }
    
    func getLocalDuplicates(remoteItems: [Item], duplicatesCallBack: @escaping WrapObjectsCallBack) {
        getLocalDuplicates { localItems in
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
            
            duplicatesCallBack(array)
        }
    }
    
    //TODO: check the usefullness of it/or need of refactor
    func getLocalFilteredItem(remoteOriginalItem: Item, localFilteredPhotosCallBack: @escaping (Item?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value = %@) AND (isFiltered == true)", remoteOriginalItem.md5, remoteOriginalItem.getTrimmedLocalID())
        
        let context = coreDataStack.newChildBackgroundContext
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
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: BoolHandler?) {
//        let context = CoreDataStack.shared.newChildBackgroundContext
        context.perform {
            guard let fetchResult = try? context.fetch(fetchRequest),
                let unwrapedObjects = fetchResult as? [NSManagedObject],
                unwrapedObjects.count > 0
            else {
                completion?(false)
                return
            }
            
            for object in unwrapedObjects {
                if let mediaItem = object as? MediaItem,
                    let relatedRemotes = mediaItem.relatedRemotes as? Set<MediaItem> {
                    relatedRemotes.forEach {
                        $0.relatedLocal = nil
                        $0.localFileID = nil
                        $0.moveToMissingDatesIfNeeded()
                    }
                }
                context.delete(object)
            }
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                completion?(true)
                debugPrint("Data base deleted objects")
            })
            
        }
    }
    
    // MARK: - MediaItemOperations
    
    //TODO: check the usefullness of it/or need of refactor
    func updateLocalItemSyncStatus(item: Item, newRemote: WrapData? = nil) {
        coreDataStack.performBackgroundTask { [weak self] context in
            #if DEBUG
            let contextQueue = DispatchQueue.currentQueueLabelAsserted
            #endif

            guard let `self` = self else {
                return
            }
            
            
            let predicateForLocalFile = NSPredicate(format: "\(#keyPath(MediaItem.isLocalItemValue)) == true AND (\(#keyPath(MediaItem.localFileID)) == %@ OR \(#keyPath(MediaItem.trimmedLocalFileID)) == %@)", item.getLocalID(), item.getTrimmedLocalID())
            
            self.executeRequest(predicate: predicateForLocalFile, context: context) { alreadySavedMediaItems in
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
                
                #if DEBUG
                let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
                assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
                #endif
                
                if let newRemoteItem = newRemote {
                    //all relation will be setuped inside
                    _ = MediaItem(wrapData: newRemoteItem, context: context)
                }

                self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: nil)
            }
        }
    }
    
    func updateRelationsAfterMerge(with uuid: String, localItem: MediaItem, context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        let predicateForRemoteFiles = NSPredicate(format: "uuid = %@ AND isLocalItemValue = false", uuid)
        
        executeRequest(predicate: predicateForRemoteFiles, context: context) { alreadySavedRemoteItems in
            alreadySavedRemoteItems.forEach {
                if $0.relatedLocal == nil {
                    $0.relatedLocal = localItem
                    localItem.addToRelatedRemotes($0)
                }
            }
            completion()
        }
    }
    
    // MARK: MediaItem
    
    func mediaItemsByIDs(ids: [NSManagedObjectID],
                         context: NSManagedObjectContext? = nil,
                         mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "self IN %@", ids)
        executeSortedRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func mediaItemByLocalID(trimmedLocalIDS: [String],
                            context: NSManagedObjectContext? = nil,
                            mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "trimmedLocalFileID IN %@ AND isLocalItemValue == true", trimmedLocalIDS)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func mediaItems(by localId: String,
                            context: NSManagedObjectContext,
                            mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(#keyPath(MediaItem.localFileID)) = %@ AND isLocalItemValue == true", localId)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func executeSortedRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.fetchLimit = limit
        request.predicate = predicate
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MediaItem.monthValue), ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.sortingDate), ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: #keyPath(MediaItem.idValue), ascending: false)
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3]
        execute(request: request, context: context, mediaItemsCallBack: mediaItemsCallBack)
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
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
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
            debugPrint("REMOTE_ITEMS: \(newItems.count) of \(remoteItems.count) remote files to add")
            
            let context = self.coreDataStack.newChildBackgroundContext
            context.perform {
                newItems.forEach { item in
                    autoreleasepool {
                        _ = MediaItem(wrapData: item, context: context)
                    }
                }
                
                self.coreDataStack.saveDataForContext(context: context, saveAndWait: true, savedCallBack: completion)
            }
            
            //      ItemOperationManager.default.addedLocalFiles(items: addedObjects)
            //WARNING:- DO we need notify ItemOperationManager here???
        }
    }
    
    func updateRemoteItems(remoteItems: [WrapData]) {
        let remoteIds = remoteItems.compactMap { $0.uuid }
        let context = coreDataStack.newChildBackgroundContext
        
        let predicate = NSPredicate(format: "\(#keyPath(MediaItem.isLocalItemValue)) = false AND (\(#keyPath(MediaItem.uuid)) IN %@)", remoteIds)
        executeRequest(predicate: predicate, context: context) { mediaItems in
            for newItem in remoteItems {
                if let existed = mediaItems.first(where: {$0.uuid == newItem.uuid}) {
                    existed.copyInfo(item: newItem, context: context)
                }
            }
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: nil)
        }
    }

    func updateRemoteItems(remoteItems: [WrapData], fileType: FileType, topInfo: RangeAPIInfo, bottomInfo: RangeAPIInfo, completion: @escaping VoidHandler) {
        let remoteIds = remoteItems.compactMap { $0.id }
        let context = coreDataStack.newChildBackgroundContext
    
        let inRangePredicate = createInRangePredicate(fileType: fileType, topInfo: topInfo, bottomInfo: bottomInfo)
        
        executeSortedRequest(predicate: inRangePredicate, limit: RequestSizeConstant.quickScrollRangeApiPageSize, context: context) { inDateRangeItems in

            debugPrint("--- remotes in date range count \(remoteItems.count)")
            debugPrint("--- count of already saved in date range \(inDateRangeItems.count)")
            
            let inDateRangeItemIds = inDateRangeItems.compactMap { $0.idValue }
            let inIdRangePredicate = NSPredicate(format:"fileTypeValue = %d AND isLocalItemValue = false AND (idValue IN %@) AND NOT (idValue IN %@)", fileType.valueForCoreDataMapping(), remoteIds, inDateRangeItemIds)
            
            self.executeRequest(predicate: inIdRangePredicate, context: context, mediaItemsCallBack: { inIdRangeItems in
                debugPrint("--- count of already saved in id range \(inIdRangeItems.count)")
                
                var allSavedItems = (inDateRangeItems + inIdRangeItems).compactMap { WrapData(mediaItem: $0) }
                debugPrint("--- count of already saved TOTAL count \(allSavedItems.count)")
                
                var deletedItems = [WrapData]()
                var newSavedItems = [WrapData]()
                
                let group = DispatchGroup()
                
                for newItem in remoteItems {
                    if let existed = allSavedItems.first(where: { $0.uuid == newItem.uuid }) {
                        if (newItem != existed || existed.hasExpiredUrl()), let objectId = existed.coreDataObjectId {
                            group.enter()
                            MediaItemOperationsService.shared.mediaItemsByIDs(ids: [objectId], context: context, mediaItemsCallBack: { items in
                                if let item = items.first {
                                    item.copyInfo(item: newItem, context: context)
                                    group.leave()
                                }
                            })
                        }
                        
                        allSavedItems.remove(existed)
                    } else {
                        newSavedItems.append(newItem)
                    }
                }

                deletedItems.append(contentsOf: allSavedItems)
                
                group.enter()
                
                #if DEBUG
                let contextQueue = DispatchQueue.currentQueueLabelAsserted
                #endif
                
                self.deleteItems(context: context, deletedItems, completion: {
                    
                    #if DEBUG
                    let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
                    assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
                    #endif
                    
                    newSavedItems.forEach {
                        ///Relations being setuped in the MediaItem init
                        _ = MediaItem(wrapData: $0, context: context)
                    }
                    group.leave()
                })
                
                group.notify(queue: DispatchQueue.global(), execute: {
                    /// we don't need check contextQueue for saveDataForContext bcz save() used in perform block
                    ///
                    /// "context.perform" added for the guard
                    context.perform {
                        self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: completion)
                    }
                })
                
            })
        }
    }
    
    private func createInRangePredicate(fileType: FileType, topInfo: RangeAPIInfo, bottomInfo: RangeAPIInfo) -> NSCompoundPredicate {
        let inDateRangePredicate = NSPredicate(format:"fileTypeValue = %d AND isLocalItemValue = false AND sortingDate != Nil AND (sortingDate <= %@ AND sortingDate >= %@)", fileType.valueForCoreDataMapping(), topInfo.date as NSDate, bottomInfo.date as NSDate)
        
        let inIdRangePredicate: NSPredicate
        if topInfo.date != bottomInfo.date {
            inIdRangePredicate = NSPredicate(value: true)
        } else {
            if let topId = topInfo.id {
                if let bottomId = bottomInfo.id {
                    inIdRangePredicate = NSPredicate(format:" (idValue <= %ld AND idValue >= %ld)", topId, bottomId)
                } else {
                    inIdRangePredicate = NSPredicate(format:"idValue <= %ld", topId)
                }
            } else if let bottomId = bottomInfo.id {
                inIdRangePredicate = NSPredicate(format:"idValue >= %ld", bottomId)
            } else {
                inIdRangePredicate = NSPredicate(value: true)
            }
        }
        
       return NSCompoundPredicate(andPredicateWithSubpredicates: [inDateRangePredicate, inIdRangePredicate])
    }
    
    func getAllRemotesMediaItem(allRemotes: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "isLocalItemValue = false")
        executeRequest(predicate: predicate, context: coreDataStack.newChildBackgroundContext, mediaItemsCallBack: allRemotes)
    }
    
    func getRemotesMediaItems(trimmedLocalIds: [String],
                              context: NSManagedObjectContext,
                              mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(#keyPath(MediaItem.isLocalItemValue)) = false AND \(#keyPath(MediaItem.trimmedLocalFileID)) IN %@", trimmedLocalIds)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func isNoRemotesInDB(result: @escaping (_ noRemotes: Bool) -> Void) {
        let predicate = NSPredicate(format: "\(#keyPath(MediaItem.isLocalItemValue)) = false")
        let fetchRequest = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        execute(request: fetchRequest, context: coreDataStack.newChildBackgroundContext) { items in
            result(items.isEmpty)
        }
    }
    
    // MARK: - LocalMediaItems
    
    @objc func processLocalMediaItems(completion: VoidHandler?) {
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
                self?.processLocalGallery(completion: completion)
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
            let assetCache = LocalMediaStorage.default.assetsCache
            assetCache.append(list: localMediaItems)
            
            self.pushToLocalsAppendingQueue(assets: localMediaItems, completion: completion)
        }
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier }, completion: completion)
    }
    
    func removeZeroBytesLocalItems(completion: @escaping BoolHandler) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicate = NSPredicate(format: "\(#keyPath(MediaItem.isLocalItemValue)) == true AND \(#keyPath(MediaItem.fileSizeValue)) == 0")
        request.predicate = predicate
        let context = coreDataStack.newChildBackgroundContext
        
        deleteObjects(fromFetch: request, context: context, completion: completion)
    }
    
    
    private let localsAppendingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    private func pushToLocalsAppendingQueue(assets: [PHAsset], completion: @escaping VoidHandler) {
        let appendOperation = AppendLocalsOperation(assets: assets, completion: completion)
        localsAppendingQueue.addOperation(appendOperation)
    }
    
    
    private func processLocalGallery(completion: VoidHandler?) {
        debugLog("processLocalGallery")
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion?()
            return
        }
        
        guard !inProcessLocalFiles else {
            return
        }
        
        inProcessLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default
        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList)
        
        pushToLocalsAppendingQueue(assets: assetsList) { [weak self] in
            self?.removeMissingLocal(assets: assetsList) { [weak self] in
                self?.inProcessLocalFiles = false
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                completion?()
            }
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        coreDataStack.performBackgroundTask { [weak self] context in
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
            let alredySavedIDs = alredySaved.compactMap { $0.localFileID }
            assetCallback(allList.filter { alredySavedIDs.contains( $0.localIdentifier ) })
        }
    }
    
    private func removeMissingLocal(assets: [PHAsset], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            self.missingLocal(assets: assets, context: context) { [weak self] missingIDs in
                guard let `self` = self else {
                    return
                }

                self.removeLocalMediaItems(with: missingIDs, completion: completion)
            }
        }
    }
    
    private func missingLocal(assets: [PHAsset], context: NSManagedObjectContext, callback: @escaping ([String]) -> ()) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback([])
            return
        }
        
        let localIdentifiers = assets.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "NOT(localFileID IN %@) AND localFileID != Nil AND isLocalItemValue == true", localIdentifiers)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            let missingIDs = mediaItems.compactMap { $0.localFileID }
            callback(missingIDs)
        })
    }

    func notSaved(assets: [PHAsset], context: NSManagedObjectContext, callback: @escaping PhotoAssetsCallback) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback([])
            return
        }
        
        let localIdentifiers = assets.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@ AND isLocalItemValue == true", localIdentifiers)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            let alredySavedIDs = mediaItems.compactMap { $0.localFileID }
            let notSaved = assets.filter { !alredySavedIDs.contains($0.localIdentifier) }
            callback(notSaved)
        })
    }
    
    
    func removeLocalMediaItems(with assetIdList: [String], completion: @escaping VoidHandler) {
        guard assetIdList.count > 0 else {
            completion()
            return
        }
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                completion()
                return
            }
            let predicate = NSPredicate(format: "localFileID IN %@ AND isLocalItemValue == true", assetIdList)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
               
                let deletedItems = mediaItems.map { WrapData(mediaItem: $0) }
                let relatedRemotes = mediaItems.compactMap { Array($0.relatedRemotes) as? Array<MediaItem>}.joined()
                relatedRemotes.forEach {
                    $0.localFileID = nil
                    $0.moveToMissingDatesIfNeeded()
                }
                
                LocalMediaStorage.default.assetsCache.remove(identifiers: assetIdList)
                ItemOperationManager.default.deleteItems(items: deletedItems)
                mediaItems.forEach { context.delete($0) }
                
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: { [weak self] in
                    ///Appearantly after recovery local ID may change, so temporary soloution is to check all files all over. and in the future chenge DataBase behavior heavily
                    let assetsList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
                    
                    self?.checkLocalFilesExistence(actualPhotoLibItemsIDs: assetsList.map{$0.localIdentifier}, complition: completion)
                })
                
            }
        }
    }
    
    func deleteItems(_ items: [WrapData], completion: @escaping VoidHandler) {
        guard !items.isEmpty else {
            completion()
            return
        }
        
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let predicate = NSPredicate(format: "uuid in %@", items.map {$0.uuid} )
            self.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { remoteItems in
                self.deleteItemsWithRelated(remoteItems, context: context, completion: completion)
            })
        }
        
        
        
        //        let predicate = NSPredicate(format: "uuid IN %@", items.compactMap { $0.uuid })
        //        delete(type: MediaItem.self, predicate: predicate, mergeChanges: true, { _ in
        //            completion()
        //        })
        
    }
    
    func deleteItems(context: NSManagedObjectContext, _ items: [WrapData], completion: @escaping VoidHandler) {
        guard !items.isEmpty else {
            completion()
            return
        }
        
        let predicate = NSPredicate(format: "uuid in %@", items.map {$0.uuid} )
        
        #if DEBUG
        let contextQueue = DispatchQueue.currentQueueLabelAsserted
        #endif
        
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { remoteItems in
            #if DEBUG
            let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
            assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
            #endif
            
            self.deleteItemsWithRelated(remoteItems, context: context) {
                #if DEBUG
                let contextQueue3 = DispatchQueue.currentQueueLabelAsserted
                assert(contextQueue == contextQueue3, "\(contextQueue) != \(contextQueue3)")
                #endif
            }
        })
        
    }
    
    func deleteTrashedItems(completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { context in
            let predicate = NSPredicate(format: "status = %d", ItemStatus.trashed.valueForCoreDataMapping())
            self.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { trashedItems in
                self.deleteItemsWithRelated(trashedItems, context: context, completion: completion)
            })
        }
    }
    
    private func deleteItemsWithRelated(_ items: [MediaItem], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        let itemsSet = NSSet(array: items)
        
        mediaItemByLocalID(trimmedLocalIDS: items.compactMap { $0.trimmedLocalFileID }, context: context, mediaItemsCallBack: { mediaItems in
            mediaItems.forEach {
                $0.removeFromRelatedRemotes(itemsSet)
                $0.updateMissingDateRelations()
                
                if $0.relatedRemotes.count == 0 {
                    $0.regenerateTrimmedLocalFileID()
                }
            }
            
            items.forEach { context.delete($0) }
            
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: completion)
        })
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
    
    func allLocalItems(localItems: @escaping WrapObjectsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "localFileID != nil")
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            localItems(mediaItems.map { $0.wrapedObject })
        })
    }
    
    func localItemsBy(assets: [PHAsset], localItemsCallback: @escaping WrapObjectsCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
        let context = coreDataStack.newChildBackgroundContext
       
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
    
    func allLocalItems(with assets: [PHAsset], localItemsCallback: @escaping WrapObjectsCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let context = coreDataStack.newChildBackgroundContext
        
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
    
    func allLocalItems(trimmedLocalIds: [String], localItemsCallBack: @escaping WrapObjectsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
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
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping WrapObjectsCallBack) {
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
        
        coreDataStack.performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@) AND (SUBQUERY(objectSyncStatus, $x, $x.userID == %@).@count == 0 AND relatedRemotes.@count = 0)", filesTypesArray, currentlyInLibriaryLocalIDs, SingletonStorage.shared.uniqueUserID)
            self?.executeRequest(predicate: predicate, context: context) { mediaItems in
                completion(mediaItems)
            }
        }
    }
    
    private func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], complition: VoidHandler? = nil) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@) AND isLocalItemValue == true", actualPhotoLibItemsIDs)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                mediaItems.forEach {
                    context.delete($0)
                }
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: {
                    /// put notification here that item deleted
                    let items = mediaItems.map { $0.wrapedObject }
                    ItemOperationManager.default.deleteItems(items: items)
                    complition?()
                })
            }
        }
    }
    
    private func checkRemoteItemsExistence(wrapData: [WrapData], completion: @escaping WrapObjectsCallBack) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "(isLocalItemValue == false) AND (uuid IN %@)", wrapData.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                let existedUUIDS = mediaItems.compactMap { $0.uuid }
                let filteredItems = wrapData.filter { !existedUUIDS.contains($0.uuid) }
                print("--- filtered \(wrapData.count - filteredItems.count) existed uuids")
                completion(filteredItems)
            }
        }
    }
    
    
    //MARK: - Hide
    func hide(_ items: [WrapData], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let isLocalItemValue = #keyPath(MediaItem.isLocalItemValue)
            let uuid = #keyPath(MediaItem.uuid)
            
            let predicate = NSPredicate(format: "\(isLocalItemValue) == false AND \(uuid) IN %@", items.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { [weak self] mediaItems in
                guard let self = self else {
                    assertionFailure("Unexpected MediaItemOperationsService == nil")
                    return
                }
                mediaItems.forEach { $0.status = ItemStatus.hidden.valueForCoreDataMapping() }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            }
        }
    }
    
    func hide(_ albums: [AlbumItem], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let albumUUID = #keyPath(MediaItemsAlbum.uuid)
            
            let predicate = NSPredicate(format: "\(albumUUID) IN %@", albums.compactMap { $0.uuid })
            let request = NSFetchRequest<MediaItemsAlbum>(entityName: MediaItemsAlbum.Identifier)
            request.predicate = predicate
            
            do {
                let savedHiddenAlbums: [MediaItemsAlbum] = try context.fetch(request)
                savedHiddenAlbums.forEach {
                    guard let items = $0.items as? Set<MediaItem> else {
                        return
                    }
                    items.forEach { $0.status = ItemStatus.hidden.valueForCoreDataMapping() }
                }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                assertionFailure(errorMessage)
            }
        }
    }
    
    //MARK: - Unhide
    func recover(_ items: [WrapData], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let isLocalItemValue = #keyPath(MediaItem.isLocalItemValue)
            let uuid = #keyPath(MediaItem.uuid)
            
            let predicate = NSPredicate(format: "\(isLocalItemValue) == false AND \(uuid) IN %@", items.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { [weak self] mediaItems in
                guard let self = self else {
                    assertionFailure("Unexpected MediaItemOperationsService == nil")
                    return
                }
                
                /// TODO: maybe we need to change status value to the related status value from recover response??
                mediaItems.forEach { $0.status = ItemStatus.active.valueForCoreDataMapping() }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            }
        }
    }
}
