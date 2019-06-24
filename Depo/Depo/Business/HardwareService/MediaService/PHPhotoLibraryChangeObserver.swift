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
}


extension LocalMediaStorage: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard fetchResult != nil, let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        self.fetchResult = changes.fetchResultAfterChanges
        if changes.hasIncrementalChanges, changes.insertedIndexes != nil || changes.removedIndexes != nil {
            let previosFetch = changes.fetchResultBeforeChanges
            var phChanges = [PhotoLibraryChangeType: [PHAsset]]()
  
            func notify() {
                NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
            }
            
            func checkDeleteIndexes() {
                if let removedIndexes = changes.removedIndexes {
                    let removedAssets = previosFetch.objects(at: removedIndexes)
                    phChanges[.removed] = removedAssets
                    debugLog("photoLibraryDidChange - removed \(removedAssets.count) items")
                    UploadService.default.cancelOperations(with: removedAssets)
                    
                    MediaItemOperationsService.shared.remove(localMediaItems: removedAssets) { 
                        notify()
                    }
                } else {
                    notify()
                }
            }
            
            if let addedIndexes = changes.insertedIndexes {
                let newAssets = self.fetchResult.objects(at: addedIndexes)
                phChanges[.added] = newAssets
                debugLog("photoLibraryDidChange - added \(newAssets.count) items")
                
                MediaItemOperationsService.shared.append(localMediaItems: newAssets) {
                    checkDeleteIndexes()
                }
            } else {
                checkDeleteIndexes()
            }

        }
    }
    
}
