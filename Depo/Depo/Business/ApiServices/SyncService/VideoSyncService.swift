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

    override func itemsSortedToUpload() -> [WrapData] {
        return CoreDataStack.default.getLocalUnsynced(fieldValue: .video)
            .filter { $0.fileSize < NumericConstants.fourGigabytes }
            .sorted(by:{$0.fileSize < $1.fileSize })
    }

    override func stop() {
        stopAllOperations()
        super.stop()
    }
    
    override func waitForWiFi() {
        stopAllOperations()
        super.waitForWiFi()
    }
    
    
    //MARK: - Private
    
    private func stopAllOperations() {
        guard self.status.isContained(in: [.prepairing, .executing]) else {
            return
        }
        
        UploadService.default.cancelSyncOperations(photo: false, video: true)
    }
}
