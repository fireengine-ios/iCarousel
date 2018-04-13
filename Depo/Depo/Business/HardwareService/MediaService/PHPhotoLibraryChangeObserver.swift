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
//        DispatchQueue.main.async {
            self.fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges, changes.insertedIndexes != nil || changes.removedIndexes != nil {
                let previosFetch = changes.fetchResultBeforeChanges
                var phChanges = [PhotoLibraryChangeType: [PHAsset]]()
                
                if let addedIndexes = changes.insertedIndexes {
                    phChanges[.added] = self.fetchResult.objects(at: addedIndexes)
                }
                
                if let removedIndexes = changes.removedIndexes {
                    phChanges[.removed] = previosFetch.objects(at: removedIndexes)
                }
                
                CoreDataStack.default.appendLocalMediaItems(completion: {
                    UploadService.default.cancelOperations(with: phChanges[.removed])
                    NotificationCenter.default.post(name: LocalMediaStorage.notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
                })
            }
//        }

    }
}
