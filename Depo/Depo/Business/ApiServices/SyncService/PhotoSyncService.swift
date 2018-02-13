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
    
    override func itemsSortedToUpload() -> [WrapData] {
        return CoreDataStack.default.getLocalUnsynced(fieldValue: .image)
            .filter { $0.fileSize < NumericConstants.fourGigabytes }
            .sorted(by: { $0.metaDate > $1.metaDate } )
    }
    
    override func stop() {
        stopAllOperations()
        super.stop()
        
        log.debug("PhotoSyncService stop")
    }
    
    override func waitForWiFi() {
        stopAllOperations()
        super.waitForWiFi()
        
        log.debug("PhotoSyncService waitForWiFi")
    }
    
    
    //MARK: - Private
    
    private func stopAllOperations() {
        guard self.status.isContained(in: [.prepairing, .executing]) else {
            return
        }
        
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
}




