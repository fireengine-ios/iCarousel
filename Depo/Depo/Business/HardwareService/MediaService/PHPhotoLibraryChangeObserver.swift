//
//  PHPhotoLibraryChangeObserver.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

extension LocalMediaStorage: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard fetchResult != nil, let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        DispatchQueue.main.async {
            self.fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges, changes.insertedIndexes != nil || changes.removedIndexes != nil {
                CoreDataStack.default.appendLocalMediaItems(progress: nil, {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocalMediaStorage.notificationPhotoLibraryDidChange),
                                                    object: nil)
                })
            }
        }

    }
}
