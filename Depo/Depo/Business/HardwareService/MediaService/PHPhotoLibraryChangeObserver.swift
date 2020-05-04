//
//  PHPhotoLibraryChangeObserver.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos


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
    private func processAssetChanges(_ changeInstance: PHChange) {
        guard fetchResult != nil, let changes = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        fetchResult = changes.fetchResultAfterChanges

        if changes.hasIncrementalChanges, changes.insertedIndexes != nil || changes.removedIndexes != nil || changes.changedIndexes != nil {
            
            let previosFetch = changes.fetchResultBeforeChanges
            var phChanges = PhotoLibraryItemsChanges()
            
            func notify() {
                NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
            }
            
            func checkChangedObjects() {
                guard let changedIndexes = changes.changedIndexes else {
                    notify()
                    return
                }
                
                let changedAssets = previosFetch.objects(at: changedIndexes)
                
                phChanges[.changed] = changedAssets
                printLog("photoLibraryDidChange - changed \(changedAssets.count) items")
                
                MediaItemOperationsService.shared.update(localMediaItems: changedAssets) {
                    notify()
                }
            }
            
            func checkDeletedObjects() {
                guard let removedIndexes = changes.removedIndexes else {
                    checkChangedObjects()
                    return
                }
                
                let removedAssets = previosFetch.objects(at: removedIndexes)
                
                phChanges[.removed] = removedAssets
                printLog("photoLibraryDidChange - removed \(removedAssets.count) items")

                UploadService.default.cancelOperations(with: removedAssets)
                
                MediaItemOperationsService.shared.remove(localMediaItems: removedAssets) {
                    checkChangedObjects()
                }
            }
            
            func checkInsertedObjects() {
                guard let insertedIndexes = changes.insertedIndexes else {
                    checkDeletedObjects()
                    return
                }
                
                let insertedAssets = fetchResult.objects(at: insertedIndexes)
                
                phChanges[.added] = insertedAssets
                
                printLog("photoLibraryDidChange - added \(insertedAssets.count) items")
                
                MediaItemOperationsService.shared.append(localMediaItems: insertedAssets, needCreateRelationships: true) {
                    checkDeletedObjects()
                }
            }
            
            checkInsertedObjects()
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
        
        if changes.hasIncrementalChanges {
            var phChanges = PhotoLibraryAlbumItemsChanges()
            
            func notify() {
                NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
            }
            
            func checkChangedObjects() {
                guard !changes.changedObjects.isEmpty else {
                    notify()
                    return
                }
                
                phChanges[.changed] = changes.changedObjects
                printLog("photoLibraryDidChange - changed \(changes.changedObjects.count) albums")
                
                MediaItemsAlbumOperationService.shared.changeAlbums(changes.changedObjects) {
                    notify()
                }
            }
            
            func checkDeletedObjects() {
                guard !changes.removedObjects.isEmpty else {
                    checkChangedObjects()
                    return
                }
                
                phChanges[.removed] = changes.removedObjects
                printLog("photoLibraryDidChange - removed \(changes.removedObjects.count) albums")
                
                MediaItemsAlbumOperationService.shared.deleteAlbums(changes.removedObjects) {
                    checkChangedObjects()
                }
            }
            
            func checkInsertedObjects() {
                guard !changes.insertedObjects.isEmpty else {
                    checkDeletedObjects()
                    return
                }
                
                phChanges[.added] = changes.insertedObjects
                printLog("photoLibraryDidChange - added \(changes.insertedObjects.count) albums")
                
                //Creation albums when handle update assets event
            }
            
            checkInsertedObjects()
        }
    }
}
