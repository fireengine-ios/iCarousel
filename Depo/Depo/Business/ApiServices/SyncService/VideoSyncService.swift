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

    override func itemsSortedToUpload(completion: @escaping WrapObjectsCallBack) {
        MediaItemOperationsService.shared.allLocalItemsForSync(video: true, image: false) { items in
            ///reversed video sync interruption fix
            //            let isMobileData = ReachabilityService.shared.isReachableViaWWAN
            let fileSizeLimit = NumericConstants.fourGigabytes //isMobileData ? NumericConstants.hundredMegabytes : NumericConstants.fourGigabytes
            
            completion(items.filter { item in
                guard item.fileSize < fileSizeLimit else {
                    return false
                }
                
                ///reversed video sync interruption fix
                //                if isMobileData {
                //                     return !self.lastInterruptedItemsUUIDs.contains(item.getTrimmedLocalID())
                //                }
                
                ///is WIFI
                return true
            })
        }
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
        
        // This tag triggering when user changes autosync preferences
//        let isWiFi = ReachabilityService.shared.isReachableViaWiFi
//        isWiFi ? MenloworksTagsService.shared.onAutosyncVideoViaWifi() : MenloworksTagsService.shared.onAutosyncVideoViaLte()
        
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


extension VideoSyncService: BackgroundTaskServiceDelegate {
    func backgroundTaskWillExpire() {
        if status == .executing, ReachabilityService.shared.isReachableViaWWAN, !lastInterruptedItemsUUIDs.isEmpty {
            storageVars.interruptedSyncVideoQueueItems = lastInterruptedItemsUUIDs
            debugLog("Interrupted autosync queue:")
            
            MediaItemOperationsService.shared.allLocalItems(trimmedLocalIds: lastInterruptedItemsUUIDs) { [weak self] mediaItems in
                mediaItems.forEach { debugLog($0.name ?? "") }
                self?.stop()
            }
        }
    }
}


extension VideoSyncService: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return object is VideoSyncService
    }
    
    func finishedUploadFile(file: WrapData) {
        lastInterruptedItemsUUIDs.remove(file.getTrimmedLocalID())
    }
}
