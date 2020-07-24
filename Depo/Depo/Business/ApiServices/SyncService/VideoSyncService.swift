//
//  VideoSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


final class VideoSyncService: ItemSyncServiceImpl {
    
    override init() {
        super.init()
        
        self.fileType = .video
        self.getUnsyncedOperationQueue.maxConcurrentOperationCount = 1
    }

    override func itemsSortedToUpload(completion: @escaping WrapObjectsCallBack) {
        debugLog("VideoSyncService itemsSortedToUpload")
        mediaItemOperationsService.allLocalItemsForSync(video: true, image: false) { items in
            let fileSizeLimit = NumericConstants.fourGigabytes
            debugLog("VideoSyncService itemsSortedToUpload completion")
            completion(items.filter { $0.fileSize < fileSizeLimit })
        }
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
    }

    override func stop() {
        stopAllOperations(networkError: false)
        super.stop()
    }
    
    override func waitForWiFi() {
        debugLog("VideoSyncService waitForWiFi")

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
        UploadService.default.cancelSyncOperations(photo: false, video: true, networkError: networkError)
    }
}
