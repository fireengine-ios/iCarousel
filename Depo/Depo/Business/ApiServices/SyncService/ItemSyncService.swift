//
//  ItemSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum AutoSyncStatus {
    case undetermined
    case waitingForWifi
    case executing
    case canceled
    case synced
    case failed
}


protocol ItemSyncService: class {
    var isMobileDataEnabled: Bool {get set}
    var status: AutoSyncStatus {get}
    
    func start(mobileData: Bool)
    func stop(mobileDataOnly: Bool)
    func interrupt()
    func waitForWiFi()
    func startManually()
}


class ItemSyncServiceImpl: ItemSyncService {
    var fileType: FileType = .unknown
    var status: AutoSyncStatus = .undetermined
    var isMobileDataEnabled: Bool = false
    
    var photoVideoService: PhotoAndVideoService?
    
    var localItems: [WrapData] = []
    var localItemsMD5s: [String] = []
    var lastSyncedMD5s: [String] = []
    
    
    init() {
        photoVideoService = PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest)
    }
    
    func start(mobileData: Bool) {
        guard !mobileData || isMobileDataEnabled else {
            status = .waitingForWifi
            return
        }
        
        guard status != .executing else {
            appendNewUnsyncedItems()
            return
        }
        
        sync()
    }
    
    func interrupt() {
        if status == .executing {
            status = .waitingForWifi
            stop(mobileDataOnly: false)
        }
    }
    
    func stop(mobileDataOnly: Bool) {
        status = .canceled
    }
    
    func waitForWiFi() {
        status = .waitingForWifi
        stop(mobileDataOnly: true)
    }
    
    func startManually() {
        sync()
    }
    
    
    private func sync() {
        status = .executing
        
        localItems.removeAll()
        localItemsMD5s.removeAll()
        
        localItems = localUnsyncedItems()

        guard !localItems.isEmpty else {
            status = .synced
            return
        }
        
        lastSyncedMD5s = localItemsMD5s
        localItemsMD5s.append(contentsOf: localItems.map({ $0.md5 }))
        
        guard let dateForCheck = localItems.first?.metaDate else {
            status = .synced
            return
        }
        
        getUnsyncedObjects(latestDate: dateForCheck, success: { [weak self] in
            if let `self` = self {
                if !self.localItems.isEmpty {
                    UploadService.default.uploadFileList(items: self.localItems,
                                                         uploadType: .autoSync,
                                                         uploadStategy: .WithoutConflictControl,
                                                         uploadTo: .MOBILE_UPLOAD,
                                                         success: {
                                                            self.status = .synced
                    }, fail: { (error) in
                        self.status = .failed
                    })
                } else {
                    self.status = .synced
                }
            }
        }) {[weak self] in
            if let `self` = self {
                self.status = .failed
            }
        }
    }
    
    private func getUnsyncedObjects(latestDate: Date, success: @escaping () -> Void, fail: @escaping () -> Void) {
        guard let service = self.photoVideoService else {
            fail()
            return
        }
        
        var finished = false
        
        service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] (items) in
            guard let `self` = self else {
                fail()
                return
            }
            
            for item in items {
                if item.metaDate.compare(latestDate) == ComparisonResult.orderedAscending {
                    finished = true
                    break
                }
                
                let serverObjectMD5 = item.md5
                if let index = self.localItemsMD5s.index(of: serverObjectMD5) {
                    let localItem = self.localItems[index]
                    localItem.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                    CoreDataStack.default.updateLocalItemSyncStatus(item: localItem)
                    
                    self.localItems.remove(at: index)
                    self.localItemsMD5s.remove(at: index)
                    
                    if self.localItems.isEmpty {
                        finished = true
                        break
                    }
                }
            }
            
            if !finished, items.count == NumericConstants.numberOfElementsInSyncRequest {
                self.getUnsyncedObjects(latestDate: latestDate, success: success, fail: fail)
            } else {
                success()
            }
            }, fail: {
                fail()
        }, newFieldValue: nil)
    }
    
    private func appendNewUnsyncedItems() {
        let unsyncedLocalItems = localUnsyncedItems()
        
        guard !unsyncedLocalItems.isEmpty else {
            return
        }
        
        UploadService.default.uploadFileList(items: unsyncedLocalItems,
                                             uploadType: .autoSync,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             success: { [weak self] in
                                                self?.status = .synced
            }, fail: { [weak self] (error) in
                self?.status = .failed
        })
    }
    
    
    func itemsToSync() -> [WrapData] {
        return []
    }
    
    func localUnsyncedItems() -> [WrapData] {
        return []
    }
}
