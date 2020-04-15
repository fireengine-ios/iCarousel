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

    func resetLocalAlbums(completion: VoidHandler?) {
        let context = coreDataStack.newChildBackgroundContext
        getLocalAlbums(context: context) { [weak self] albums in
            albums.forEach { $0.isEnabled = true }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
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
                
                self.inProcessLocalAlbums = false
                self.isAlbumsActualized = true
                
                if self.waitingLocalAlbumsCallBack != nil {
                    self.getAutoSyncAlbums(context: context) { [weak self] albums in
                        self?.waitingLocalAlbumsCallBack?(albums)
                        self?.waitingLocalAlbumsCallBack = nil
                    }
                }
                completion()
            })
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
                    }
                }
            }
            
            //TODO: Notify observers of renaming albums
            
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
