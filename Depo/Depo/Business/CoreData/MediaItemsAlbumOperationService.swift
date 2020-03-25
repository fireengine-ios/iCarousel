//
//  MediaItemsAlbumOperationService.swift
//  Depo
//
//  Created by Andrei Novikau on 3/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

typealias MediaItemRemoteAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsAlbum]) -> Void
typealias MediaItemLocalAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsLocalAlbum]) -> Void
typealias PhotoAssetCollectionsCallback = (_ assets: [PHAssetCollection]) -> Void

final class MediaItemsAlbumOperationService {

    static let shared = MediaItemsAlbumOperationService()

    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var localMediaStorage = LocalMediaStorage.default
    private lazy var localAlbumsCache = LocalAlbumsCache.shared
    private lazy var albumService = AlbumService(requestSize: 200)
    
    var inProcessLocalAlbums = false
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemAlbumsOperationsService, attributes: .concurrent)
    
    private var waitingLocalAlbumsCallBack: MediaItemLocalAlbumsCallBack?
    
    //MARK: -
    
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
    
    func getAutoSyncAlbums(albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        if inProcessLocalAlbums {
            waitingLocalAlbumsCallBack = albumsCallBack
            return
        }
        
        let context = coreDataStack.newChildBackgroundContext
        getLocalAlbums(context: context, albumsCallBack: albumsCallBack)
    }
    
    func save(selectedAlbums: [AutoSyncAlbum]) {
        let localIdentifiers = selectedAlbums.map { $0.uuid }
        let context = coreDataStack.newChildBackgroundContext
        
        getLocalAlbums(context: context) { [weak self] mediaItemAlbums in
            guard let self = self else {
                return
            }
            
            var changedAlbums = [MediaItemsLocalAlbum]()
            
            mediaItemAlbums.forEach { album in
                if let localId = album.localId {
                    let newValue = localIdentifiers.contains(localId)
                    if newValue != album.isEnabled {
                        album.isEnabled = newValue
                        changedAlbums.append(album)
                    }
                }
            }
            
            //update isAvailable for related MediaItems
            self.updateRelatedItems(for: changedAlbums)
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: nil)
        }
    }
    
    func getLocalAlbums(localIds: [String]? = nil, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        
        let sortDescriptor1 = NSSortDescriptor(key: MediaItemsLocalAlbum.PropertyNameKey.isMain, ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: MediaItemsLocalAlbum.PropertyNameKey.name, ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        let fetchRequest: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        
        if let localIds = localIds {
            fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.localId) IN %@", localIds)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        execute(request: fetchRequest, context: context, albumsCallBack: albumsCallBack)
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
        
        localMediaStorage.getLocalAlbums { [weak self] albums in
            guard let self = self else {
                return
            }
            
            let context = self.coreDataStack.newChildBackgroundContext
            
            self.saveLocalAlbums(assets: albums, context: context, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                func callback() {
                    self.inProcessLocalAlbums = false
                    
                    if self.waitingLocalAlbumsCallBack != nil {
                        self.getLocalAlbums(context: context) { [weak self] albums in
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
    
    private func saveLocalAlbums(assets: [PHAssetCollection], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard localMediaStorage.photoLibraryIsAvailible() else {
            completion()
            return
        }
        
        getLocalAlbums(context: context) { [weak self] mediaItemAlbums in
            guard let self = self else {
                return
            }
            
            var renamedAlbumsIds = [String]()
            
            assets.forEach { asset in
                if let album = mediaItemAlbums.first(where: { $0.localId == asset.localIdentifier }) {
                    if album.name != asset.localizedTitle {
                        album.name = asset.localizedTitle
                        album.updateRelatedRemoteAlbums(context: context)
                        
                        if asset.assetCollectionType == .album {
                            renamedAlbumsIds.append(asset.localIdentifier)
                        }
                    }
                } else {
                    //create new local albums
                    _ = MediaItemsLocalAlbum(asset: asset, context: context)
                }
            }
            
            //TODO: Notify observers of renaming albums
            
            //delete unused albums (empty or deleted)

            var deletedAlbums = [MediaItemsLocalAlbum]()
            
            let localIdentifiers = assets.map { $0.localIdentifier }
            mediaItemAlbums.forEach { album in
                if let localId = album.localId, !localIdentifiers.contains(localId) {
                    deletedAlbums.append(album)
                    context.delete(album)
                }
            }
            
            if !deletedAlbums.isEmpty {
                self.updateRelatedItems(for: deletedAlbums)
            }
            
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    private func appendAlbumsToBase(assets: [PHAssetCollection], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        context.perform { [weak self] in
            assets.forEach {
                _ = MediaItemsLocalAlbum(asset: $0, context: context)
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
                    if asset.assetCollectionType == .album, album.name != asset.localizedTitle {
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
}

//MARK: - Common Request Methods

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
