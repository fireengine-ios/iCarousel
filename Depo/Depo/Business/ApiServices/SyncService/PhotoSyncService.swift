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
    }
    
    override func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {
        CoreDataStack.default.getLocalUnsynced(fieldValue: .image, service: photoVideoService) { items in
            DispatchQueue.toBackground {
                completion(items.filter { $0.fileSize < NumericConstants.fourGigabytes }.sorted(by: { $0.metaDate > $1.metaDate }))
            }
        }
    }
    
    override func start(newItems: Bool) {
        super.start(newItems: newItems)
        
        let isWiFi = ReachabilityService().isReachableViaWiFi
        isWiFi ? MenloworksTagsService.shared.onAutosyncPhotosViaWifi() : MenloworksTagsService.shared.onAutosyncPhotosViaLte()
        
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
        
        photoVideoService.stopAllOperations()
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
}
