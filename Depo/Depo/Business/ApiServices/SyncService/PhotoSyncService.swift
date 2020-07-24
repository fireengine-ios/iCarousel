//
//  PhotoSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


final class PhotoSyncService: ItemSyncServiceImpl {
    
    override init() {
        super.init()
        
        self.fileType = .image
        self.getUnsyncedOperationQueue.maxConcurrentOperationCount = 1
    }
    
    override func itemsSortedToUpload(completion: @escaping WrapObjectsCallBack) {
        debugLog("PhotoSyncService itemsSortedToUpload")
        mediaItemOperationsService.allLocalItemsForSync(video: false, image: true) { items in
            debugLog("PhotoSyncService itemsSortedToUpload completion")
            completion(items.filter { $0.fileSize < NumericConstants.fourGigabytes }.sorted(by: { $0.metaDate > $1.metaDate }))
        }
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
    }
    
    override func stop() {
        stopAllOperations(networkError: false)
        super.stop()
        
        debugLog("PhotoSyncService stop")
    }
    
    override func waitForWiFi() {
        debugLog("PhotoSyncService waitForWiFi")
        
        stopAllOperations(networkError: true)
        super.waitForWiFi()
    }
    
    
    // MARK: - Private
    
    private func stopAllOperations(networkError: Bool) {
        guard self.status.isContained(in: [.prepairing, .executing]) else {
            return
        }
        
        getUnsyncedOperationQueue.cancelAllOperations()
        photoVideoService.stopAllOperations()
        UploadService.default.cancelSyncOperations(photo: true, video: false, networkError: networkError)
    }
}
