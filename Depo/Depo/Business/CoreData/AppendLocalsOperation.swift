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
    private let coreDataStack = CoreDataStack.default
    private let context = CoreDataStack.default.newChildBackgroundContext
    private let mediaStorage = LocalMediaStorage.default
    
    
    init(assets: [PHAsset], completion: VoidHandler?) {
        self.completionHandler = completion
        self.assets = assets
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
                assetsInfo.forEach { element in
                    autoreleasepool {
                        let wrapedItem = WrapData(info: element)
                        _ = MediaItem(wrapData: wrapedItem, context: self.context)
                        
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
