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
    
    private var localItemsArray = [WrapData]()
    private var localMD5Array = [String]()
    
    override init() {
        operations = OperationQueue()
        operations.maxConcurrentOperationCount = 1
        
        super.init()
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startSyncImmediately),
                                               name: NSNotification.Name(rawValue: LocalMediaStorage.notificationPhotoLibraryDidChange),
                                               object: nil)
    }
    
    @objc func startSyncImmediately() {
        timeLastAutoSync = NSDate().timeIntervalSince1970
        
        self.startAutoSync()
    }
    
    func startSync(imageViaWiFiOnly: Bool, videoViaWiFiOnly: Bool) {
        if (isSyncing){
            return
        }
        
        let isWiFi = ReachabilityService().isReachableViaWiFi
        if (!isWiFi && imageViaWiFiOnly && videoViaWiFiOnly){
            return
        }
        
        localItemsArray.removeAll()
        localMD5Array.removeAll()
        
        isSyncing = true
        allObjectsHaveBeenUploaded = false
        itemsFromServer.removeAll()
        self.photoVideoService = PhotoAndVideoService(requestSize: numberElementsInRequest)
        
        let localItems = self.allLocalNotSyncItems(video: isWiFi ? true : !videoViaWiFiOnly,
                                                   image: isWiFi ? true : !imageViaWiFiOnly)
        
        if (localItems.count == 0){
            isSyncing = false
            return
        }
        
        var latestDate: Date? = nil
        
        for object in localItems {
            if object.fileSize < NumericConstants.fourGigabytes {
                localItemsArray.append(object)
                if latestDate == nil {
                    latestDate = object.creationDate
                }else{
                    guard let date = object.creationDate else{
                        continue
                    }
                    if latestDate!.compare(date) == ComparisonResult.orderedDescending {
                        latestDate = object.creationDate
                    }
                }
            }else{
                //
            }
        }
        localMD5Array.append(contentsOf: localItemsArray.map({ $0.md5 }))
        
        guard let dateForCheck = latestDate else {
            isSyncing = false
            return
        }
        
        getUnsyncedObjects(latestDate: dateForCheck, success: { [weak self] in
            if let self_ = self {
                if self_.localItemsArray.count > 0 {
                    UploadService.default.uploadFileList(items: self_.localItemsArray,
                                                         uploadType: .autoSync,
                                                         uploadStategy: .WithoutConflictControl,
                                                         uploadTo: .MOBILE_UPLOAD,
                                                         success:{
                                                            self_.isSyncing = false
                    }, fail: { (error) in
                        self_.isSyncing = false
                    })
                }else{
                    self_.isSyncing = false
                }
            }
        }) {[weak self] in
            if let self_ = self {
                self_.isSyncing = false
            }
        }
    }
    
    
    
    fileprivate func startAutoSync() {
        AutoSyncDataStorage().getAutoSyncModelForCurrentUser(success: { [weak self] (models, uniqueUserId) in
            let autoSyncEnable = models[SettingsAutoSyncModel.autoSyncEnableIndex]
            if (autoSyncEnable.isSelected){
                let imageSyncViaWiFi = !models[SettingsAutoSyncModel.mobileDataPhotosIndex].isSelected
                let videoSyncViaWiFi = !models[SettingsAutoSyncModel.mobileDataVideoIndex].isSelected
                self?.startSync(imageViaWiFiOnly: imageSyncViaWiFi, videoViaWiFiOnly: videoSyncViaWiFi)
            }
        })
    }
    
    func startAutoSyncInBG(){
        let time = NSDate().timeIntervalSince1970
        if time - timeLastAutoSync > NumericConstants.timeIntervalBetweenAutoSync{
            timeLastAutoSync = time
            
            startAutoSync()
        }
    }
    
    private func getUnsyncedObjects(latestDate: Date,
                                      success: @escaping ()-> Swift.Void,
                                      fail: @escaping ()-> Swift.Void){
        
        guard let service = self.photoVideoService else{
            fail()
            return
        }
        var finished = false
        
        service.nextItems(sortBy: .date, sortOrder: .desc, success: { [weak self] (items) in
            guard let self_ = self else{
                fail()
                return
            }
            
            for item in items{
                if let date = item.creationDate, date.compare(latestDate) == ComparisonResult.orderedAscending{
                    finished = true
                    break
                }
                let serverObjectMD5 = item.md5
                let index = self_.localMD5Array.index(of: serverObjectMD5)
                if let index_ = index {
                    
                    let localItem = self_.localItemsArray[index_]
                    localItem.syncStatus = .synced
                    CoreDataStack.default.updateLocalItemSyncStatus(item: localItem)
                    
                    self_.localItemsArray.remove(at: index_)
                    self_.localMD5Array.remove(at: index_)
                    
                    if (self_.localItemsArray.count == 0){
                        finished = true
                        break
                    }
                }
            }
            
            if (!finished) && (items.count == self_.numberElementsInRequest){
                self_.getUnsyncedObjects(latestDate: latestDate, success: success, fail: fail)
            }else{
                success()
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
    
    func allLocalNotSyncItems(video: Bool, image: Bool) -> [WrapData] {
        return CoreDataStack.default.allLocalItemsForSync(video:video, image:image)
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
