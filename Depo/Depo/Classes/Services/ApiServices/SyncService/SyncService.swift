//
//  SyncService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SyncService: NSObject {
    
    static let `default` = SyncService()
    
    private let operations: OperationQueue
    private var timeLastAutoSync: TimeInterval = 0
    private var isSyncing: Bool = false
    private var itemsFromServer = [WrapData]()
    private let numberElementsInRequest = 100
    private var allObjectsHaveBeenUploaded = false
    private var photoVideoService : PhotoAndVideoService? = nil
    
    override init() {
        operations = OperationQueue()
        operations.maxConcurrentOperationCount = 1
        super.init()
    }
    
    func startSync(imageViaWiFiOnly: Bool, videoViaWiFiOnly: Bool) {
        if (isSyncing){
            return
        }
        
        let isWiFi = ReachabilityService().isReachableViaWiFi
        if (!isWiFi && imageViaWiFiOnly && videoViaWiFiOnly){
            return
        }
        
        isSyncing = true
        allObjectsHaveBeenUploaded = false
        itemsFromServer.removeAll()
        self.photoVideoService = PhotoAndVideoService(requestSize: numberElementsInRequest)
        getAllServerObjects(success: {
            
            let serverObjectHash = self.itemsFromServer.map({$0.md5})

            let notSyncedItems = self.allLocalNotSyncItems(md5Array: serverObjectHash,
                                                           video: isWiFi ? true : !videoViaWiFiOnly,
                                                           image: isWiFi ? true : !imageViaWiFiOnly)

            if (notSyncedItems.count > 0){
                UploadService.default.uploadFileList(items: notSyncedItems,
                                                     uploadType: .autoSync,
                                                     uploadStategy: .WithoutConflictControl,
                                                     uploadTo: .MOBILE_UPLOAD,
                                                     success:{
                                                        self.isSyncing = false
                }, fail: { (error) in
                    self.isSyncing = false
                })
            }else{
                self.isSyncing = false
            }
            
        }) {
            self.isSyncing = false
        }
    }
    
    func startAutoSyncInBG(){
        let time = NSDate().timeIntervalSince1970
        if time - timeLastAutoSync > NumericConstants.timeIntervalBetweenAutoSync{
            timeLastAutoSync = time
            
            AutoSyncDataStorage().getAutoSyncModelForCurrentUser(success: { [weak self] (models, uniqueUserId) in
                let autoSyncEnable = models[SettingsAutoSyncModel.autoSyncEnableIndex]
                if (autoSyncEnable.isSelected){
                    let imageSyncViaWiFi = !models[SettingsAutoSyncModel.mobileDataPhotosIndex].isSelected
                    let videoSyncViaWiFi = !models[SettingsAutoSyncModel.mobileDataVideoIndex].isSelected
                    self?.startSync(imageViaWiFiOnly: imageSyncViaWiFi, videoViaWiFiOnly: videoSyncViaWiFi)
                }
            })
        }
    }
    
    private func getAllServerObjects(success: @escaping ()-> Swift.Void, fail: @escaping ()-> Swift.Void){
        guard let service = self.photoVideoService else {
            fail()
            return
        }
        
        guard !allObjectsHaveBeenUploaded else {
            success()
            return
        }
        
        service.nextItemsWithoutDBChanges(sortBy: .date, sortOrder: .asc, success: { [weak self] (items) in
            if let `self` = self {
                self.itemsFromServer.append(contentsOf: items)
                self.allObjectsHaveBeenUploaded = (items.count != self.numberElementsInRequest)
                self.getAllServerObjects(success: {
                    print("\(self.itemsFromServer.count)")
                }, fail: {
                    fail()
                })
            }
            }, fail: {
                fail()
        }, newFieldValue: nil)
    }
    
    func stopSync() {
        if (isSyncing){
            photoVideoService?.stopAllOperations()
            UploadService.default.cancelOperations()
            isSyncing = false
        }
    }
    
    func pause() {
        
    }
    
    func allLocalItems() -> [WrapData] {
        return CoreDataStack.default.allLocalItem()
    }
    
    func allLocalNotSyncItems(md5Array: [String], video: Bool, image: Bool) -> [WrapData] {
        return CoreDataStack.default.allLocalNotSyncedItems(md5Array: md5Array,
                                                            video: video,
                                                            image: image)
    }
    
    func updateSyncSettings(setting: SettingsAutoSyncModel) {
        stopSync()
        
        if setting.isAutoSyncEnable {
            startSync(imageViaWiFiOnly: !setting.mobileDataPhotos, videoViaWiFiOnly: !setting.mobileDataVideo)
        } else {
            stopSync()
        }
    }
}
