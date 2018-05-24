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
    
    override func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {
        let operation = GetLocalUnsyncedOperation(service: photoVideoService, fieldValue: .image) { items in
            DispatchQueue.toBackground {
                completion(items.filter { $0.fileSize < NumericConstants.fourGigabytes }.sorted(by: { $0.metaDate > $1.metaDate }))
            }
        }
        getUnsyncedOperationQueue.addOperation(operation)
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
        
        // This tag triggering when user changes autosync preferences
//        let isWiFi = ReachabilityService().isReachableViaWiFi
//        isWiFi ? MenloworksTagsService.shared.onAutosyncPhotosViaWifi() : MenloworksTagsService.shared.onAutosyncPhotosViaLte()
        
    }
    
    override func stop() {
        stopAllOperations()
        super.stop()
        
        log.debug("PhotoSyncService stop")
    }
    
    override func waitForWiFi() {
        log.debug("PhotoSyncService waitForWiFi")
        
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
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
}
