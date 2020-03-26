//
//  AppendLocalsOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 15/08/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


final class AppendLocalsOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var completionHandler: VoidHandler?
    private var assets = [PHAsset]()
    private let itemOperationService = MediaItemOperationsService.shared
    private let coreDataStack: CoreDataStack = factory.resolve()
    private let context: NSManagedObjectContext
    private let mediaStorage = LocalMediaStorage.default
    private let needCreateRelationships: Bool
    private lazy var localAlbumsCache = LocalAlbumsCache.shared
    
    
    init(assets: [PHAsset], needCreateRelationships: Bool, completion: VoidHandler?) {
        context = coreDataStack.newChildBackgroundContext
        self.completionHandler = completion
        self.assets = assets
        self.needCreateRelationships = needCreateRelationships
    }
    
    override func cancel() {
        super.cancel()
        // checking isCancelled on every step in main
    }
    
    override func main() {
        
        guard !assets.isEmpty, LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completionHandler?()
            return
        }
        
        itemOperationService.notSaved(assets: assets, context: context) { [weak self] notSaved in
            guard let self = self else {
                return
            }
            
            guard !self.isCancelled, self.mediaStorage.photoLibraryIsAvailible() else {
                self.semaphore.signal()
                self.completionHandler?()
                return
            }
            
            self.saveLocalMediaItemsPaged(items: notSaved, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.semaphore.signal()
                self.completionHandler?()
            })
        }
        semaphore.wait()
    }
    
    private func saveLocalMediaItemsPaged(items: [PHAsset], completion: @escaping VoidHandler) {
        guard !items.isEmpty, !isCancelled, LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        
        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))
        mediaStorage.getInfo(from: nextItemsToSave, completion: { [weak self] info in
            guard let self = self, !self.isCancelled else {
                completion()
                return
            }
            
            self.context.perform { [weak self] in
                guard let self = self, !self.isCancelled else {
                    completion()
                    return
                }
                
                var addedObjects = [WrapData]()
                let updatedCache = self.mediaStorage.assetsCache
                let assetsInfo = info.filter { $0.isValid && updatedCache.assetBy(identifier: $0.asset.localIdentifier) != nil }
                
                let smartAssets = PHAssetCollection.smartAlbums.map { (album: $0, assets: $0.allAssets) }
                
                assetsInfo.forEach { element in
                    autoreleasepool {
                        if self.needCreateRelationships {
                            var albums = element.asset.containingAlbums
                            let smartAlbums = smartAssets.filter { $0.assets.contains(element.asset) }.map { $0.album }
                            
                            albums.append(contentsOf: smartAlbums)
                            albums.forEach {
                                self.localAlbumsCache.append(albumId: $0.localIdentifier, with: [element.asset.localIdentifier])
                            }
                            
                            //FE-2354 Logs for debug
                            //TODO: Delete after debugging
                            debugLog("asset name - \(element.asset.originalFilename ?? "")")
                            let albumsString = albums.map { $0.localizedTitle ?? "" }.joined(separator: ",")
                            debugLog("containing albums - \(albumsString)")
                            
                            debugPrint("asset name - \(element.asset.originalFilename ?? "")")
                            debugPrint("containing albums - \(albumsString)")
                        }
                        
                        let wrapedItem = WrapData(info: element)
                        _ = MediaItem(wrapData: wrapedItem, context: self.context)
                        
                        debugLog("local_appended: \(wrapedItem.name ?? "_EMPTY_")")
                        
                        addedObjects.append(wrapedItem)
                    }
                }
                self.coreDataStack.saveDataForContext(context: self.context, saveAndWait: true, savedCallBack: { [weak self] in
                    ItemOperationManager.default.addedLocalFiles(items: addedObjects)
                    
                    guard let self = self, !self.isCancelled else {
                        completion()
                        return
                    }
                    
                    self.saveLocalMediaItemsPaged(items: Array(items.dropFirst(nextItemsToSave.count)), completion: completion)
                })
            }
        })
    }
}
