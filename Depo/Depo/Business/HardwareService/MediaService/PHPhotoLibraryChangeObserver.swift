//
//  PHPhotoLibraryChangeObserver.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos
import WidgetKit


enum PhotoLibraryChangeType: String {
    case added = "added"
    case removed = "removed"
    case changed = "changed"
}

typealias PhotoLibraryItemsChanges = [PhotoLibraryChangeType: [PHAsset]]
typealias PhotoLibraryAlbumItemsChanges = [PhotoLibraryChangeType: [PHAssetCollection]]

extension LocalMediaStorage: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        processAssetChanges(changeInstance)
        processAlbumsChanges(changeInstance)
        processSmartAlbumsChanges(changeInstance)
        
    }
    
    private func processAssetAccessLevel(changes: PHFetchResultChangeDetails<PHAsset>) {
        if #available(iOS 14.0, *) {
            var hasChanges = false
            
            var before = [PHAsset]()
            var after = [PHAsset]()
            
            changes.fetchResultBeforeChanges.enumerateObjects { asset, _, _ in
                before.append(asset)
            }
            changes.fetchResultAfterChanges.enumerateObjects { asset, _, _ in
                after.append(asset)
            }
            
            debugLog("PHASSETS before: \(before.count), PHASSETS after: \(after.count)")
            
            if before.count == after.count {
                hasChanges = !before.elementsEqual(after) { (assetBefore, assetAfter) -> Bool in
                    assetBefore == assetAfter
                }
            } else {
                hasChanges = true
            }
            
            guard hasChanges else {
                printLog("PHASSETS doesn't have changes")
                return
            }
            
            let newSelectedAssets = Array(Set(after).subtracting(before))
            let deselectedAssets = Array(Set(before).subtracting(after))
            
            var phChanges = PhotoLibraryItemsChanges()
            
            phChanges[.added] = newSelectedAssets
            phChanges[.removed] = deselectedAssets
            
            debugLog("PHASSETS newSelectedAssets: \(newSelectedAssets.count),\nPHASSETS deselectedAssets: \(deselectedAssets.count)")
            
            MediaItemOperationsService.shared.append(localMediaItems: newSelectedAssets, needCreateRelationships: true) { [weak self] in
                MediaItemOperationsService.shared.remove(localMediaItems: deselectedAssets) {
                    self?.updateHomeWidget()
                    
                    NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
                }
            }
        }
        
        debugLog("PHASSETS inserted: \(changes.insertedObjects.count),\nPHASSETS removed: \(changes.removedObjects.count),\nPHASSETS changed: \(changes.changedObjects.count)")
    }
    
    private func processAssetChanges(_ changeInstance: PHChange) {
        guard fetchResult != nil else {
            printLog("photoLibraryDidChange - fetchResult is nil")
            return
        }
        
        guard let changes = changeInstance.changeDetails(for: fetchResult) else {
            printLog("photoLibraryDidChange - no changes")
            return
        }
        
        fetchResult = changes.fetchResultAfterChanges

        guard changes.hasIncrementalChanges else {
            processAssetAccessLevel(changes: changes)
            printLog("photoLibraryDidChange - no incremental changes")
            return
        }
          
        var phChanges = PhotoLibraryItemsChanges()
        
        func notify() {
            updateHomeWidget()
            
            NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
        }
        
        
        func checkChangedObjects() {
            let changedAssets = changes.changedObjects
            
            guard !changedAssets.isEmpty else {
                notify()
                return
            }
            
            phChanges[.changed] = changedAssets
            printLog("photoLibraryDidChange - changed \(changedAssets.count) assets")
            
            MediaItemOperationsService.shared.update(localMediaItems: changedAssets) {
                notify()
            }
        }
        
        func checkDeletedObjects() {
            let removedAssets = changes.removedObjects
            
            guard !removedAssets.isEmpty else {
                checkChangedObjects()
                return
            }
            
            phChanges[.removed] = removedAssets
            printLog("photoLibraryDidChange - removed \(removedAssets.count) assets")
            
            UploadService.default.cancelOperations(with: removedAssets)
            
            MediaItemOperationsService.shared.remove(localMediaItems: removedAssets) {
                checkChangedObjects()
            }
        }
        
        func checkInsertedObjects() {
            let insertedAssets = changes.insertedObjects
            
            guard !insertedAssets.isEmpty else {
                checkDeletedObjects()
                return
            }
            
            phChanges[.added] = insertedAssets
            
            printLog("photoLibraryDidChange - added \(insertedAssets.count) assets")
            
            MediaItemOperationsService.shared.append(localMediaItems: insertedAssets, needCreateRelationships: true) {
                checkDeletedObjects()
            }
        }
        
        checkInsertedObjects()
    }
    
    private func updateHomeWidget() {
        let mediaService = MediaItemOperationsService.shared
        mediaService.allUnsyncedLocalIds { unsyncedLocalIds in
            mediaService.allLocalIds(subtractingIds: unsyncedLocalIds) { syncedLocalIds in
                SharedGroupCoreDataStack.shared.actualizeWith(synced: syncedLocalIds, unsynced: unsyncedLocalIds) {
                    debugLog("SharedGroupCoreDataStack is actualized")
                    if #available(iOS 14.0, *) {
                        guard !SyncServiceManager.shared.hasExecutingSync else {
                            debugLog("Widgets reload will not be called. hasExecutingSync")
                            return
                        }
                        debugLog("Widgets reload is called")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }
    
    
    private func processAlbumsChanges(_ changeInstance: PHChange) {
        guard fetchAlbumResult != nil, let changes = changeInstance.changeDetails(for: fetchAlbumResult) else {
            return
        }

        debugPrint("processingAlbumsChanges")
        fetchAlbumResult = changes.fetchResultAfterChanges
        
        processAlbums(changes)
    }

    private func processSmartAlbumsChanges(_ changeInstance: PHChange) {
        guard fetchSmartAlbumResult != nil, let changes = changeInstance.changeDetails(for: fetchSmartAlbumResult) else {
            return
        }
        
        debugPrint("processingSmartAlbumsChanges")
        fetchSmartAlbumResult = changes.fetchResultAfterChanges
        
        processAlbums(changes)
    }

    
    private func processAlbums(_ changes: PHFetchResultChangeDetails<PHAssetCollection>) {
        guard changes.hasIncrementalChanges else {
            return
        }
        
        var phChanges = PhotoLibraryAlbumItemsChanges()
        
        func notify() {
            NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
        }
        
        func checkChangedObjects() {
            let changedAlbums = changes.changedObjects
            
            guard !changedAlbums.isEmpty else {
                notify()
                return
            }
            
            phChanges[.changed] = changedAlbums
            printLog("photoLibraryDidChange - changed \(changedAlbums.count) albums")
            
            MediaItemsAlbumOperationService.shared.changeAlbums(changedAlbums) {
                notify()
            }
        }
        
        func checkDeletedObjects() {
            let removedAlbums = changes.removedObjects
            
            guard !removedAlbums.isEmpty else {
                checkChangedObjects()
                return
            }
            
            phChanges[.removed] = removedAlbums
            printLog("photoLibraryDidChange - removed \(removedAlbums.count) albums")
            
            MediaItemsAlbumOperationService.shared.deleteAlbums(removedAlbums) {
                checkChangedObjects()
            }
        }
        
        func checkInsertedObjects() {
            let insertedAlbums = changes.insertedObjects
            
            guard !insertedAlbums.isEmpty else {
                checkDeletedObjects()
                return
            }
            
            phChanges[.added] = insertedAlbums
            printLog("photoLibraryDidChange - added \(insertedAlbums.count) albums")
            
            //Creation albums when handle update assets event
        }
        
        checkInsertedObjects()
    }
}
