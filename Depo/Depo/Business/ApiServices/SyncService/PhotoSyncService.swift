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
    
    override func localUnsyncedItems() -> [WrapData] {
        return CoreDataStack.default.allLocalItemsForSync(video:false, image:true)
            .filter({$0.fileSize < NumericConstants.fourGigabytes})
            .sorted(by:{$0.metaDate > $1.metaDate})
    }
    
    override func interrupt() {
        super.interrupt()
        
        log.debug("PhotoSyncService interrupt")
        
        stopAllOperations()
    }
    
    override func stop() {
        super.stop()
        
        log.debug("PhotoSyncService stop")
        
        stopAllOperations()
    }
    
    override func waitForWiFi() {
        super.waitForWiFi()
        
        log.debug("PhotoSyncService waitForWiFi")
        
        stopAllOperations()
    }
    
    
    //MARK: - Private
    
    private func stopAllOperations() {
        UploadService.default.cancelSyncOperations(photo: true, video: false)
        
        if let service = photoVideoService {
            service.stopAllOperations()
        }
    }
}
