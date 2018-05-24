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

    override func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {
        let operation = LocalUnsyncedOperation(service: photoVideoService, fieldValue: .video) { items in
            DispatchQueue.toBackground {
                completion(items.filter { $0.fileSize < NumericConstants.fourGigabytes }.sorted(by: { $0.fileSize < $1.fileSize }))
            }
        }
        getUnsyncedOperationQueue.addOperation(operation)
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
        
        // This tag triggering when user changes autosync preferences
//        let isWiFi = ReachabilityService().isReachableViaWiFi
//        isWiFi ? MenloworksTagsService.shared.onAutosyncVideoViaWifi() : MenloworksTagsService.shared.onAutosyncVideoViaLte()
        
    }

    override func stop() {
        stopAllOperations()
        super.stop()
    }
    
    override func waitForWiFi() {
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
