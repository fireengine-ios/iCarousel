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
    case prepairing
    case executing
    case canceled
    case synced
    case failed
}


public let autoSyncStatusDidChangeNotification = NSNotification.Name("AutoSyncStatusChangedNotification")


protocol ItemSyncService: class {
    var status: AutoSyncStatus {get}
    
    func start()
    func stop()
    func interrupt()
    func waitForWiFi()
    func startManually()
}


class ItemSyncServiceImpl: ItemSyncService {
    var fileType: FileType = .unknown
    var status: AutoSyncStatus = .undetermined {
        didSet {
            postNotification()
        }
    }
    
    var photoVideoService: PhotoAndVideoService?
    
    var localItems: [WrapData] = []
    var localItemsMD5s: [String] = []
    var lastSyncedMD5s: [String] = []
    
    
    //MARK: - init
    
    init() {
        photoVideoService = PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest)
    }
    
    
    //MARK: - Public ItemSyncService functions
    
    func start() {
        guard !status.isContained(in: [.executing, .prepairing]) else {
            appendNewUnsyncedItems()
            return
        }
        
        sync()
    }
    
    func interrupt() {
//        if status == .executing {
            status = .waitingForWifi
//        }
    }
    
    func stop() {
        status = .canceled
    }
    
    func waitForWiFi() {
        status = .waitingForWifi
    }
    
    func startManually() {
        DispatchQueue.main.async {
            self.sync()
        }
    }
    
    
    //MARK: - Private
    
    private func sync() {
        guard !status.isContained(in: [.executing, .prepairing]) else {
            return
        }
        
        status = .prepairing
        
        localItems.removeAll()
        localItemsMD5s.removeAll()
        
        localItems = localUnsyncedItems()

        guard !localItems.isEmpty else {
            status = .synced
            return
        }
        
        localItemsMD5s.append(contentsOf: localItems.map({ $0.md5 }))
        lastSyncedMD5s = localItemsMD5s
        
        guard let oldestItemDate = localItems.last?.metaDate else {
            status = .synced
            return
        }
        
        getUnsyncedObjects(oldestItemDate: oldestItemDate, success: { [weak self] in
            if let `self` = self {
                guard !self.localItems.isEmpty else {
                    self.status = .synced
                    return
                }
                
                self.upload(items: self.localItems)
            }
        }) {[weak self] in
            if let `self` = self {
                self.status = .failed
            }
        }
    }
    
    private func upload(items: [WrapData]) {
        guard !items.isEmpty else {
            return
        }
        
//        if status != .executing {
            status = .executing
//        }
        
        UploadService.default.uploadFileList(items: items.sorted(by:{$0.fileSize < $1.fileSize}),
                                             uploadType: .autoSync,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             success: { [weak self] in
                                                self?.status = .synced
        }, fail: { [weak self] (error) in
            if case ErrorResponse.httpCode(413) = error {
                self?.status = .failed
                self?.stop()
                
                //TODO: add popup 'out of space'
                
            }
            
        })
        
    }
    
    private func getUnsyncedObjects(oldestItemDate: Date, success: @escaping () -> Void, fail: @escaping () -> Void) {
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
                if item.metaDate < oldestItemDate {
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
                self.getUnsyncedObjects(oldestItemDate: oldestItemDate, success: success, fail: fail)
            } else {
                success()
            }
            }, fail: {
                fail()
        }, newFieldValue: nil)
    }
    
    private func appendNewUnsyncedItems() {
        DispatchQueue.main.async {
            let newUnsyncedLocalItems = self.localUnsyncedItems().filter({ !self.lastSyncedMD5s.contains($0.md5) })
            guard !newUnsyncedLocalItems.isEmpty else {
                return
            }
            
            self.upload(items: newUnsyncedLocalItems)
        }
    }
    
    private func postNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: autoSyncStatusDidChangeNotification, object: nil)
        }
    }
    
    
    //MARK: - Override me
    
    func itemsToSync() -> [WrapData] {
        return []
    }
    
    func localUnsyncedItems() -> [WrapData] {
        return []
    }
}
