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
        
        ItemOperationManager.default.startUpdateView(view: self)
        self.backgroundTaskService.expirationDelegates.add(self)
        self.fileType = .video
        self.getUnsyncedOperationQueue.maxConcurrentOperationCount = 1
    }

    override func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {
        let operation = LocalUnsyncedOperation(service: photoVideoService, fieldValue: .video) { items in
            let isMobileData = ReachabilityService().isReachableViaWWAN
            let fileSizeLimit = isMobileData ? NumericConstants.hundredMegabytes : NumericConstants.fourGigabytes
            
            completion(items.filter { item in
                guard item.fileSize < fileSizeLimit else {
                    return false
                }
                
                if isMobileData {
                     return !self.lastInterruptedItemsUUIDs.contains(item.getTrimmedLocalID())
                }

                ///is WIFI
                return true
            }.sorted(by: { $0.fileSize < $1.fileSize }))
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


extension VideoSyncService: BackgroundTaskServiceDelegate {
    func backgroundTaskWillExpire() {
        if status == .executing, ReachabilityService().isReachableViaWWAN {
            debugLog("interrupted_queue_items")
            storageVars.interruptedSyncVideoQueueItems = lastInterruptedItemsUUIDs
            stop()
        }
    }
}


extension VideoSyncService: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return true
    }
    
    func finishedUploadFile(file: WrapData) {
        lastInterruptedItemsUUIDs.remove(file.getTrimmedLocalID())
    }
}
