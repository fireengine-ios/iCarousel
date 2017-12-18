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
    }
    
    override func localUnsyncedItems() -> [WrapData] {
        return CoreDataStack.default.allLocalItemsForSync(video:true, image:false)
            .filter({$0.fileSize < NumericConstants.fourGigabytes})
            .sorted(by:{$0.metaDate > $1.metaDate})
    }
    
    override func interrupt() {
        super.interrupt()
        
        photoVideoService?.stopAllOperations()//FIXME: stop only video sync
        UploadService.default.cancelSyncOperations(photo: false, video: true)
    }

    override func stop() {
        super.stop()
        
        photoVideoService?.stopAllOperations()//FIXME: stop only video sync
        UploadService.default.cancelSyncOperations(photo: false, video: true)
    }
}
