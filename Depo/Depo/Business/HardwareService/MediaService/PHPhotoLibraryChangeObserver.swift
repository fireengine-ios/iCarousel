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
        DispatchQueue.main.async {
            self.fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges, changes.insertedIndexes != nil || changes.removedIndexes != nil {
                let previosFetch = changes.fetchResultBeforeChanges
                
                if let addedIndexes = changes.insertedIndexes {
                    var phChanges = [PhotoLibraryChangeType: [PHAsset]]()
                    let addedItems = self.fetchResult.objects(at: addedIndexes)
                    phChanges[.added] = addedItems
                    CoreDataStack.default.append(localMediaItems: addedItems, completion: {
                        NotificationCenter.default.post(name: LocalMediaStorage.notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
                    })
                }
                
                if let removedIndexes = changes.removedIndexes {
                    var phChanges = [PhotoLibraryChangeType: [PHAsset]]()
                    let removedItems = previosFetch.objects(at: removedIndexes)
                    phChanges[.removed] = removedItems
                    CoreDataStack.default.remove(localMediaItems: removedItems, completion: {
                        UploadService.default.cancelOperations(with: removedItems)
                        NotificationCenter.default.post(name: LocalMediaStorage.notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
                    })
                }
            }
        }

    }
}
