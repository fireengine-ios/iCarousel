//
//  MediaItemsAlbumOperationService.swift
//  Depo
//
//  Created by Andrei Novikau on 3/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

typealias MediaItemAlbumsCallBack = (_ mediaItemAlbums: [MediaItemsAlbum]) -> Void
typealias PhotoAssetCollectionsCallback = (_ assets: [PHAssetCollection]) -> Void

final class MediaItemsAlbumOperationService {

    static let shared = MediaItemsAlbumOperationService()

    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var localMediaStorage = LocalMediaStorage.default
    
    var inProcessLocalAlbums = false
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemAlbumsOperationsService, attributes: .concurrent)
    
    private var waitingLocalAlbumsCallBack: MediaItemAlbumsCallBack?
    
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
                self?.inProcessLocalAlbums = false
                
                if let callback = self?.waitingLocalAlbumsCallBack {
                    self?.getLocalAlbums(mediaItemAlbumsCallBack: callback)
                    self?.waitingLocalAlbumsCallBack = nil
                }
            })
        }
    }
    
    func getLocalAlbums(mediaItemAlbumsCallBack: @escaping MediaItemAlbumsCallBack) {
        if inProcessLocalAlbums {
            waitingLocalAlbumsCallBack = mediaItemAlbumsCallBack
            return
        }
        
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(#keyPath(MediaItemsAlbum.isLocal)) == true")
        executeRequest(predicate: predicate, context: context, mediaItemAlbumsCallBack: mediaItemAlbumsCallBack)
    }
    
    func saveLocalAlbums(assets: [PHAssetCollection], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard localMediaStorage.photoLibraryIsAvailible() else {
            completion()
            return
        }
                
        notSaved(assets: assets, context: context) { [weak self] newAssets in
            guard let self = self else {
                return
            }
            
            newAssets.forEach { asset in
                let _ = MediaItemsAlbum(asset: asset, context: context)
            }
            self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
        }
    }
    
    func notSaved(assets: [PHAssetCollection], context: NSManagedObjectContext, callback: @escaping PhotoAssetCollectionsCallback) {
        guard localMediaStorage.photoLibraryIsAvailible() else {
            callback([])
            return
        }
        
        let localIdentifiers = assets.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "\(#keyPath(MediaItemsAlbum.localId)) IN %@ AND \(#keyPath(MediaItemsAlbum.isLocal)) == true", localIdentifiers)
        executeRequest(predicate: predicate, context: context) { mediaItemsAlbums in
            let alredySavedIDs = mediaItemsAlbums.compactMap { $0.localId }
            let notSaved = assets.filter { !alredySavedIDs.contains($0.localIdentifier) }
            callback(notSaved)
        }
    }
 
    func executeRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, mediaItemAlbumsCallBack: @escaping MediaItemAlbumsCallBack) {
        let request: NSFetchRequest = MediaItemsAlbum.fetchRequest()
        request.fetchLimit = limit
        request.predicate = predicate
        execute(request: request, context: context, mediaItemAlbumsCallBack: mediaItemAlbumsCallBack)
    }
    
    func execute(request: NSFetchRequest<MediaItemsAlbum>, context: NSManagedObjectContext, mediaItemAlbumsCallBack: @escaping MediaItemAlbumsCallBack) {
        context.perform {
            var result: [MediaItemsAlbum] = []
            do {
                result = try context.fetch(request)
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            mediaItemAlbumsCallBack(result)
        }
    }
    
}
