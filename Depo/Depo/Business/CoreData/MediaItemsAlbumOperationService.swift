//
//  MediaItemsAlbumOperationService.swift
//  Depo
//
//  Created by Andrei Novikau on 3/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

typealias AutoSyncAlbumsCallBack = (_ albums: [AutoSyncAlbum]) -> Void
typealias MediaItemRemoteAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsAlbum]) -> Void
typealias MediaItemLocalAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsLocalAlbum]) -> Void
typealias PhotoAssetCollectionsCallback = (_ assets: [PHAssetCollection]) -> Void

private enum RelationshipsChangesType {
    case append
    case delete
}

final class MediaItemsAlbumOperationService {

    static let shared = MediaItemsAlbumOperationService()

    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var localMediaStorage = LocalMediaStorage.default
    private lazy var localAlbumsCache = LocalAlbumsCache.shared
    private lazy var albumService = AlbumService(requestSize: 200)
    private lazy var mediaItemsService = MediaItemOperationsService.shared
    
    var inProcessLocalAlbums = false
    private var isAlbumsActualized = false
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemAlbumsOperationsService, attributes: .concurrent)
    
    private var waitingLocalAlbumsCallBack: AutoSyncAlbumsCallBack?
    
    //MARK: - Public
    
    func processLocalMediaItemAlbums(completion: @escaping VoidHandler) {
        guard !localMediaStorage.isWaitingForPhotoPermission else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] _, status in
            switch status {
            case .denied:
                completion()
            case .authorized:
                self?.processLocalGallery(completion: completion)
            case .restricted, .notDetermined:
                break
            }
        }
    }
    
    func getAutoSyncAlbums(albumsCallBack: @escaping AutoSyncAlbumsCallBack) {
        if !isAlbumsActualized || inProcessLocalAlbums {
            waitingLocalAlbumsCallBack = albumsCallBack
            return
        }
        
        let context = coreDataStack.newChildBackgroundContext
        getAutoSyncAlbums(context: context, albumsCallBack: albumsCallBack)
    }
    
    func saveAutoSyncAlbums(_ albums: [AutoSyncAlbum]) {
        let localIdentifiers = albums.map { $0.uuid }
        let context = coreDataStack.newChildBackgroundContext
        
        getLocalAlbums(localIds: localIdentifiers, context: context) {  [weak self] mediaItemAlbums in
            guard let self = self else {
                return
            }
            
            var changedAlbums = [MediaItemsLocalAlbum]()
            
            albums.forEach { album in
                if let mediaAlbum = mediaItemAlbums.first(where: { $0.localId == album.uuid }),
                    mediaAlbum.isEnabled != album.isSelected {
                    mediaAlbum.isEnabled = album.isSelected
                    changedAlbums.append(mediaAlbum)
                }
            }
            
            //update isAvailable for related MediaItems
            self.updateRelatedItems(for: changedAlbums)
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: {
                if !changedAlbums.isEmpty {
                    NotificationCenter.default.post(name: .localAlbumStatusDidChange, object: nil)
                }
            })
        }
    }
}

//MARK: - Public Local Albums Actions

extension MediaItemsAlbumOperationService {

    func resetLocalAlbums() {
        let context = coreDataStack.newChildBackgroundContext
        getLocalAlbums(context: context) { [weak self] albums in
            albums.forEach { $0.isEnabled = true }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: nil)
        }
    }

    func getLocalAlbums(localIds: [String]? = nil, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        let fetchRequest: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        
        if let localIds = localIds {
            fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.localId) IN %@", localIds)
        }
        
        execute(request: fetchRequest, context: context, albumsCallBack: albumsCallBack)
    }
    
    func createLocalAlbumsIfNeeded(localIds: [String], context: NSManagedObjectContext) {
        privateQueue.sync { [weak self] in
            guard let self = self else {
                return
            }

            let semaphore = DispatchSemaphore(value: 0)
            self.getLocalAlbums(localIds: localIds, context: context) { mediaItemAlbums in
                let mediaItemAlbumsIds = Set(mediaItemAlbums.compactMap { $0.localId })
                let newAlbumIds = Set(localIds).subtracting(mediaItemAlbumsIds)

                if !newAlbumIds.isEmpty {
                    let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: Array(newAlbumIds), options: nil)
                    fetchResult.enumerateObjects { asset, _, _ in
                        let hasItems = asset.photosCount > 0 || asset.videosCount > 0
                        _ = MediaItemsLocalAlbum(asset: asset, hasItems: hasItems, context: context)
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    private func getAutoSyncAlbums(context: NSManagedObjectContext, albumsCallBack: @escaping AutoSyncAlbumsCallBack) {
        let fetchRequest: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        
        let sortDescriptor1 = NSSortDescriptor(key: MediaItemsLocalAlbum.PropertyNameKey.isMain, ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: MediaItemsLocalAlbum.PropertyNameKey.name, ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        if CacheManager.shared.isCacheActualized {
            fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.items).@count > 0")
        } else {
            fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.hasItems) = true")
        }
        
        execute(request: fetchRequest, context: context) { mediaItemAlbums in
            let albums = mediaItemAlbums.map { AutoSyncAlbum(mediaItemAlbum: $0) }
            albumsCallBack(albums)
        }
    }
}

//MARK: - Public Remote Albums Actions

extension MediaItemsAlbumOperationService {
    
    func createRemoteAlbums(albums: [AlbumItem], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        context.perform { [weak self] in
            albums.forEach { album in
                _ = MediaItemsAlbum(uuid: album.uuid, name: album.name, context: context)
            }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    func createNewRemoteAlbum(_ albumItem: AlbumItem, completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        context.perform {
            _ = MediaItemsAlbum(uuid: albumItem.uuid, name: albumItem.name, context: context)
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    func deleteRemoteAlbums(_ albumItems: [AlbumItem], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        let uuids = albumItems.map { $0.uuid }
        getRemoteAlbums(uuids: uuids, context: context) { [weak self] remoteAlbums in
            remoteAlbums.forEach { context.delete($0) }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    func getLocalAlbumsToSync(for itemId: NSManagedObjectID, callback: @escaping MediaItemLocalAlbumsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        
        let fetchRequest: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.isEnabled) = true AND \(MediaItemsLocalAlbum.PropertyNameKey.relatedRemote) = NULL AND %@ IN \(MediaItemsLocalAlbum.PropertyNameKey.items)", itemId)
        
        execute(request: fetchRequest, context: context, albumsCallBack: callback)
    }

    
    func remoteAlbumRenamed(_ albumUuid: String, newName: String, completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        
        getRemoteAlbums(uuids: [albumUuid], context: context) { [weak self] remoteAlbums in
            guard let self = self, let album = remoteAlbums.first else {
                return
            }
            album.name = newName
            album.updateRelatedLocalAlbum(context: context)
            
            //TODO: Notify observers
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }

    func addItemsToRemoteAlbum(itemsUuids: [String], albumUuid: String, completion: @escaping VoidHandler) {
        changeRelationships(type: .append, itemsUuids: itemsUuids, albumUuid: albumUuid, completion: completion)
    }
    
    func removeItemsFromRemoteAlbum(itemsUuids: [String], albumUuid: String, completion: @escaping VoidHandler) {
        changeRelationships(type: .delete, itemsUuids: itemsUuids, albumUuid: albumUuid, completion: completion)
    }
    
    private func changeRelationships(type: RelationshipsChangesType, itemsUuids: [String], albumUuid: String, completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        getRemoteAlbums(uuids: [albumUuid], context: context) { [weak self] remoteAlbums in
            guard
                let self = self,
                let album = remoteAlbums.first(where: { $0.uuid == albumUuid })
            else {
                completion()
                return
            }
            
            self.mediaItemsService.mediaItems(by: itemsUuids, context: context) { [weak self] mediaItems in
                switch type {
                case .append:
                    album.addToItems(NSSet(array: mediaItems))
                case .delete:
                    album.removeFromItems(NSSet(array: mediaItems))
                }
                
                self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
            }
        }
    }
}

//MARK: - PhotoLibraryChangeObserver Events

extension MediaItemsAlbumOperationService {
    
    func appendNewAlbums(_ assets: [PHAssetCollection], _ completion: @escaping VoidHandler) {
        appendAlbumsToBase(assets: assets, completion: completion)
    }
    
    func deleteAlbums(_ assets: [PHAssetCollection], _ completion: @escaping VoidHandler) {
        deleteAlbumsFromBase(assets: assets, completion: completion)
    }
    
    func changeAlbums(_ assets: [PHAssetCollection], _ completion: @escaping VoidHandler) {
        updateAlbums(assets: assets, completion: completion)
    }
    
}

//MARK: - Private

extension MediaItemsAlbumOperationService {
    
    private func processLocalGallery(completion: @escaping VoidHandler) {
        debugLog("processLocalGallery")
        guard localMediaStorage.photoLibraryIsAvailible() else {
            completion()
            return
        }
        
        guard !inProcessLocalAlbums else {
            return
        }
        
        inProcessLocalAlbums = true
        isAlbumsActualized = false
        
        localMediaStorage.getLocalAlbums { [weak self] response in
            guard let self = self else {
                return
            }
          
            let context = self.coreDataStack.newChildBackgroundContext
            
            self.saveLocalAlbums(assetsResponse: response, context: context, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                func callback() {
                    self.inProcessLocalAlbums = false
                    self.isAlbumsActualized = true
                    
                    if self.waitingLocalAlbumsCallBack != nil {
                        self.getAutoSyncAlbums(context: context) { [weak self] albums in
                            self?.waitingLocalAlbumsCallBack?(albums)
                            self?.waitingLocalAlbumsCallBack = nil
                        }
                    }
                    completion()
                }

                self.getAllRemoteAlbums { response in
                    switch response {
                    case .success(let remoteAlbums):
                        self.updateRemoteAlbums(remoteAlbums, context: context, completion: callback)
                    case .failed(let error):
                        debugPrint(error.description)
                        callback()
                    }
                }
            })
        }
    }
    
    func actualizeRemoteAlbums(completion: @escaping BoolHandler) {
        guard isAlbumsActualized, !inProcessLocalAlbums else {
            completion(false)
            return
        }
        
        isAlbumsActualized = false
        
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                completion(false)
                return
            }
            
            let callback = { [weak self] in
                self?.isAlbumsActualized = true
                
                if self?.waitingLocalAlbumsCallBack != nil {
                    self?.getAutoSyncAlbums(context: context) { albums in
                        self?.waitingLocalAlbumsCallBack?(albums)
                        self?.waitingLocalAlbumsCallBack = nil
                    }
                }
                completion(true)
            }
            
            self.getAllRemoteAlbums { response in
                switch response {
                case .success(let remoteAlbums):
                    self.updateRemoteAlbums(remoteAlbums, context: context, completion: callback)
                case .failed(let error):
                    debugPrint(error.description)
                    completion(false)
                }
            }
        }
    }
    
    private func saveLocalAlbums(assetsResponse: LocalAssetsResponse, context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard localMediaStorage.photoLibraryIsAvailible() else {
            completion()
            return
        }
        
        getLocalAlbums(context: context) { [weak self] mediaItemAlbums in
            guard let self = self else {
                return
            }
            
            //TODO: Notify observers of renaming albums
            var renamedAlbumsIds = [String]()
            
            assetsResponse.forEach { asset, hasItems in
                if let album = mediaItemAlbums.first(where: { $0.localId == asset.localIdentifier }) {
                    if album.name != asset.localizedTitle {
                        album.name = asset.localizedTitle
                        album.updateRelatedRemoteAlbums(context: context)
                        
                        renamedAlbumsIds.append(asset.localIdentifier)
                    }
                    album.hasItems = hasItems
                } else {
                    //create new local albums
                    _ = MediaItemsLocalAlbum(asset: asset, hasItems: hasItems, context: context)
                }
            }
            
            //delete albums

            let localIdentifiers = assetsResponse.map { $0.asset.localIdentifier }
            let deletedAlbums = mediaItemAlbums.filter { album -> Bool in
                if let localId = album.localId, localIdentifiers.contains(localId) {
                    return false
                }
                return true
            }
            
            if !deletedAlbums.isEmpty {
                deletedAlbums.forEach { context.delete($0) }
                self.updateRelatedItems(for: deletedAlbums)
            }
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    private func appendAlbumsToBase(assets: [PHAssetCollection], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        context.perform { [weak self] in
            assets.forEach {
                let hasItems = $0.photosCount > 0 || $0.videosCount > 0
                _ = MediaItemsLocalAlbum(asset: $0, hasItems: hasItems, context: context)
            }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    private func deleteAlbumsFromBase(assets: [PHAssetCollection], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        let localIds = assets.map { $0.localIdentifier }
        getLocalAlbums(localIds: localIds, context: context, albumsCallBack: { [weak self] mediaItemAlbums in
            guard let self = self else {
                return
            }
            
            mediaItemAlbums.forEach { album in
                context.delete(album)
            }
            
            self.updateRelatedItems(for: mediaItemAlbums)
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        })
    }
    
    private func updateAlbums(assets: [PHAssetCollection], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        let localIds = assets.map { $0.localIdentifier }
        getLocalAlbums(localIds: localIds, context: context) { [weak self] mediaItemAlbums in
            var renamedAlbumsIds = [String]()
            assets.forEach { asset in
                if let album = mediaItemAlbums.first(where: { $0.localId == asset.localIdentifier }) {
                    if album.name != asset.localizedTitle {
                        album.name = asset.localizedTitle
                        renamedAlbumsIds.append(album.localId)
                        album.updateRelatedRemoteAlbums(context: context)
                    }
                }
            }
            
            //TODO: Notify observers of renaming albums
            
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    private func updateRemoteAlbums(_ albums: [AlbumItem], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        let request: NSFetchRequest = MediaItemsAlbum.fetchRequest()
        
        execute(request: request, context: context) { [weak self] mediaItemAlbums in
            let uuids = Set(albums.map { $0.uuid })
            let mediaUuids = Set(mediaItemAlbums.compactMap { $0.uuid })
            
            let appendAlbumsUuids = Array(uuids.subtracting(mediaUuids))
            let deletedAlbumsUuids = mediaUuids.subtracting(uuids)
            
            var renamedAlbumsUuid = [String]()

            let deletedAlbums = mediaItemAlbums.filter { deletedAlbumsUuids.contains($0.uuid ?? "") }
            deletedAlbums.forEach {
                context.delete($0)
            }
            
            albums.forEach { remoteAlbum in
                if appendAlbumsUuids.contains(remoteAlbum.uuid) {
                    //create new album
                    _ = MediaItemsAlbum(uuid: remoteAlbum.uuid, name: remoteAlbum.name, context: context)
                } else if let album = mediaItemAlbums.first(where: { $0.uuid == remoteAlbum.uuid }) {
                    //update album
                    if album.name != remoteAlbum.name {
                        renamedAlbumsUuid.append(remoteAlbum.uuid)
                        album.name = remoteAlbum.name
                        album.updateRelatedLocalAlbum(context: context)
                    }
                }
            }
            
            //TODO: Processing renamedAlbumsUuid
            
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    private func getAllRemoteAlbums(completion: @escaping ResponseArrayHandler<AlbumItem>) {
        albumService.allAlbums(sortBy: .albumName, sortOrder: .asc, success: { albums in
            completion(.success(albums))
        }, fail: {
            completion(.failed(ErrorResponse.string("Failed get remote albums")))
        })
    }
    
    private func updateRelatedItems(for albums: [MediaItemsLocalAlbum]) {
        let updatedItems = NSMutableSet()
        
        albums.forEach { album in
            guard let items = album.items?.array as? [MediaItem] else {
                return
            }
            
            if album.isDeleted {
                let mediaItemsLocalIds = items.compactMap { $0.localFileID }
                if let localId = album.localId {
                    localAlbumsCache.remove(albumId: localId, with: mediaItemsLocalIds)
                }
                items.forEach {
                    $0.removeFromLocalAlbums(album)
                }
                updatedItems.addObjects(from: items)
            } else if album.isEnabled {
                items.forEach {
                    $0.isAvailable = true
                }
            } else {
                updatedItems.addObjects(from: items)
            }
        }
        
        guard let mediaItems = updatedItems.allObjects as? [MediaItem] else {
            return
        }
        
        mediaItems.forEach { $0.updateAvalability() }
    }
}

//MARK: - Local Albums Request Methods

extension MediaItemsAlbumOperationService {
    
    private func executeRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        let request: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        request.fetchLimit = limit
        request.predicate = predicate
        execute(request: request, context: context, albumsCallBack: albumsCallBack)
    }
    
    private func execute(request: NSFetchRequest<MediaItemsLocalAlbum>, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        context.perform {
            var result: [MediaItemsLocalAlbum] = []
            do {
                result = try context.fetch(request)
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            albumsCallBack(result)
        }
    }
}

//MARK: - Remote Albums Request Methods

extension MediaItemsAlbumOperationService {
    
    private func getRemoteAlbums(uuids: [String], context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemRemoteAlbumsCallBack) {
        let request: NSFetchRequest = MediaItemsAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "\(MediaItemsAlbum.PropertyNameKey.uuid) IN %@", uuids)
        execute(request: request, context: context, albumsCallBack: albumsCallBack)
    }
    
    private func execute(request: NSFetchRequest<MediaItemsAlbum>, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemRemoteAlbumsCallBack) {
        context.perform {
            var result: [MediaItemsAlbum] = []
            do {
                result = try context.fetch(request)
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            albumsCallBack(result)
        }
    }
}
