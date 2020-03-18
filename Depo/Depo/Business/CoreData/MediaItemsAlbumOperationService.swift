//
//  MediaItemsAlbumOperationService.swift
//  Depo
//
//  Created by Andrei Novikau on 3/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

typealias MediaItemLocalAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsLocalAlbum]) -> Void
typealias PhotoAssetCollectionsCallback = (_ assets: [PHAssetCollection]) -> Void

final class MediaItemsAlbumOperationService {

    static let shared = MediaItemsAlbumOperationService()

    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var localMediaStorage = LocalMediaStorage.default
    
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
        waitingLocalAlbumsCallBack = nil
        
        let context = coreDataStack.newChildBackgroundContext
        getLocalAlbums(context: context, albumsCallBack: albumsCallBack)
    }
    
    func save(selectedAlbums: [AutoSyncAlbum]) {
        let localIdentifiers = selectedAlbums.map { $0.uuid }
        let context = coreDataStack.newChildBackgroundContext
        
        getLocalAlbums(context: context) { [weak self] mediaItemAlbums in
            mediaItemAlbums.forEach { album in
                if let localId = album.localId {
                    album.isEnabled = localIdentifiers.contains(localId)
                }
            }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: nil)
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
        
        localMediaStorage.getLocalAlbums { [weak self] albums in
            guard let self = self else {
                return
            }
            
            let context = self.coreDataStack.newChildBackgroundContext
            
            self.saveLocalAlbums(assets: albums, context: context, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.inProcessLocalAlbums = false
                
                if let callback = self.waitingLocalAlbumsCallBack {
                    self.getLocalAlbums(context: context, albumsCallBack: callback)
                }
                completion()
            })
        }
    }
    
    private func getLocalAlbums(localIds: [String]? = nil, context: NSManagedObjectContext, albumsCallBack: @escaping MediaItemLocalAlbumsCallBack) {
        
        let sortDescriptor1 = NSSortDescriptor(key: MediaItemsLocalAlbum.PropertyNameKey.isMain, ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: MediaItemsAlbum.PropertyNameKey.name, ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        let fetchRequest: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        
        if let localIds = localIds {
            fetchRequest.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.localId) IN %@", localIds)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        execute(request: fetchRequest, context: context, albumsCallBack: albumsCallBack)
    }
    
    private func saveLocalAlbums(assets: [PHAssetCollection], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard localMediaStorage.photoLibraryIsAvailible() else {
            completion()
            return
        }
        
        getLocalAlbums(context: context) { [weak self] mediaItemAlbums in
            assets.forEach { asset in
                if let album = mediaItemAlbums.first(where: { $0.localId == asset.localIdentifier }) {
                    //update names for current locale
                    album.name = asset.localizedTitle
                } else {
                    //create new local albums
                    _ = MediaItemsLocalAlbum(asset: asset, context: context)
                }
            }
            
            //delete unused albums (empty or deleted)
            let localIdentifiers = assets.map { $0.localIdentifier }
            mediaItemAlbums.forEach { album in
                if let localId = album.localId, !localIdentifiers.contains(localId) {
                    context.delete(album)
                }
            }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
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
            //TODO: need to remove relationships
            mediaItemAlbums.forEach { context.delete($0) }
            self?.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        })
    }
    
    private func updateAlbums(assets: [PHAssetCollection], completion: @escaping VoidHandler) {
        let context = coreDataStack.newChildBackgroundContext
        let localIds = assets.map { $0.localIdentifier }
        getLocalAlbums(localIds: localIds, context: context) { [weak self] mediaItemAlbums in
            //TODO: maybe need to update relationships
            assets.forEach { asset in
                if let album = mediaItemAlbums.first(where: { $0.localId == asset.localIdentifier }) {
                    album.name = asset.localizedTitle
                }
            }
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
}
