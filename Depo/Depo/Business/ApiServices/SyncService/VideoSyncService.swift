//
//  VideoSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


final class VideoSyncService: ItemSyncServiceImpl {
    private let backgroundTaskService = BackgroundTaskService.shared
    
    
    override init() {
        super.init()
        
        self.fileType = .video
        self.getUnsyncedOperationQueue.maxConcurrentOperationCount = 1
    }

    override func itemsSortedToUpload(completion: @escaping WrapObjectsCallBack) {
        MediaItemOperationsService.shared.allLocalItemsForSync(video: true, image: false) { items in
            let fileSizeLimit = NumericConstants.fourGigabytes
            completion(items.filter { $0.fileSize < fileSizeLimit })
        }
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
    }

    override func stop() {
        stopAllOperations()
        super.stop()
    }
    
    override func waitForWiFi() {
        debugLog("VideoSyncService waitForWiFi")

        stopAllOperations()
        super.waitForWiFi()
    }
    
    
    // MARK: - Private
    
    private func stopAllOperations() {
        guard self.status.isContained(in: [.prepairing, .executing]) else {
            return
        }
        
        getUnsyncedOperationQueue.cancelAllOperations()
        photoVideoService.stopAllOperations()
        UploadService.default.cancelSyncOperations(photo: false, video: true)
    }
}
