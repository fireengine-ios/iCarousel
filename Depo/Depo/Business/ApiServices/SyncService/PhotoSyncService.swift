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
        
        photoVideoService?.stopAllOperations()//FIXME: stop only photo sync
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
    
    override func stop() {
        super.stop()
        
        photoVideoService?.stopAllOperations()//FIXME: stop only photo sync
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
    
    override func waitForWiFi() {
        super.waitForWiFi()
        
        photoVideoService?.stopAllOperations()//FIXME: stop only photo sync
        UploadService.default.cancelSyncOperations(photo: true, video: false)
    }
}
