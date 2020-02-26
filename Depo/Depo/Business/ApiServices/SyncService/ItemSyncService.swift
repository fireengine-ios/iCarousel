//
//  ItemSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


protocol ItemSyncService: class {
    var status: AutoSyncStatus { get }
    weak var delegate: ItemSyncServiceDelegate? { get set }
    
    func start(newItems: Bool)
    func stop()
    func fail()
    func waitForWiFi()
}


protocol ItemSyncServiceDelegate: class {
    func didReceiveOutOfSpaceError()
    func didReceiveError()
}


class ItemSyncServiceImpl: ItemSyncService {
    
    var fileType: FileType = .unknown
    var status: AutoSyncStatus = .undetermined {
        didSet {
            if oldValue != status {
                debugPrint("AUTOSYNC: \(fileType) status = \(status)")
                postNotification()
            }
        }
    }
    
    var localItems: [WrapData] = []
    var lastSyncedMD5s: [String] = []
    var storageVars: StorageVars = factory.resolve()
    
    var photoVideoService: PhotoAndVideoService {
        let fieldValue: FieldValue = (fileType == .image) ? .image : .video
        return PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest, type: fieldValue)
    }
    
    var getUnsyncedOperationQueue = OperationQueue()
    
    weak var delegate: ItemSyncServiceDelegate?
    
    
    // MARK: - Public ItemSyncService functions
    
    func start(newItems: Bool) {
        debugLog("ItemSyncServiceImpl start")
        
        guard CacheManager.shared.isCacheActualized else {
            /// don't need to change status because it's fake preparation until CoreData processing is done
//            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            return
        }
        
        guard !(newItems && status.isContained(in: [.prepairing, .executing])) else {
            appendNewUnsyncedItems()
            return
        }
        
        sync()
    }
    
    func stop() {
        debugLog("ItemSyncServiceImpl stop")
        
        lastSyncedMD5s.removeAll()
        
        if status != .synced {
            status = .stoped
        }
    }
    
    func waitForWiFi() {
        debugLog("ItemSyncServiceImpl waitForWiFi")
        
        lastSyncedMD5s.removeAll()
        
        status = .waitingForWifi
        
        MediaItemOperationsService.shared.hasLocalItemsForSync(video: fileType == .video, image: fileType == .image) { [weak self] hasItemsToSync in
            guard let self = self else {
                return
            }
            
            if self.status == .waitingForWifi, !hasItemsToSync {
                self.status = .stoped
            }
        }
    }
    
    func fail() {
        debugLog("ItemSyncServiceImpl fail")
        
        lastSyncedMD5s.removeAll()
        status = .failed
    }
    
    // MARK: - Private
    
    private func sync() {
        debugLog("ItemSyncServiceImpl sync")

        guard !status.isContained(in: [.executing, .prepairing]) else {
            return
        }
        
        status = .prepairing
        
        localItems.removeAll()
        itemsSortedToUpload { [weak self] items in
            guard let `self` = self else {
                return
            }
            
            if self.status == .prepairing {
                self.localItems = items
                self.lastSyncedMD5s = self.localItems.map { $0.md5 }
                
                guard !self.localItems.isEmpty else {
                    self.status = .synced
                    return
                }
                
                self.upload(items: self.localItems)
            }
        }
        
    }
    
    private func upload(items: [WrapData]) {
        debugLog("ItemSyncServiceImpl upload")

        guard !items.isEmpty, status != .stoped else {
            return
        }
        
        UploadService.default.uploadFileList(items: items,
                                             uploadType: .autoSync,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             success: { [weak self] in
                                                debugLog("ItemSyncServiceImpl upload UploadService uploadFileList success")
                                                if self?.status == .executing {
                                                    self?.status = .synced
                                                }
        }, fail: { [weak self] error in
            guard let `self` = self else {
                print("\(#function): self == nil")
                return
            }
            
            debugLog("ItemSyncServiceImpl upload UploadService uploadFileList fail")
            
            if error.description == TextConstants.canceledOperationTextError || error.description == TextConstants.networkConnectionLostTextError {
                return
            }
            
            if error.isOutOfSpaceError {
                self.delegate?.didReceiveOutOfSpaceError()
            } else {
                self.delegate?.didReceiveError()
            }
            
            self.fail()
            
            }, returnedUploadOperation: { [weak self] operations in
                guard self?.status != .executing else {
                    /// status == .executing
                    /// means that uploading is already in progress and we've just appended new items
                    return
                }
                
                if let operations = operations, !operations.isEmpty {
                    self?.status = .executing
                } else {
                    self?.status = .synced
                }
        })
    }
    
    private func appendNewUnsyncedItems() {
        itemsSortedToUpload { [weak self] items in
            guard let `self` = self else {
                return
            }
            
            let newUnsyncedLocalItems = items.filter({ !self.lastSyncedMD5s.contains($0.md5) })
            
            guard !newUnsyncedLocalItems.isEmpty else {
                return
            }
            
            self.lastSyncedMD5s.append(contentsOf: newUnsyncedLocalItems.map { $0.md5 })
            
            self.upload(items: newUnsyncedLocalItems)
        }
    }
    
    private func postNotification() {
        ///affects ItemSyncOperation, do not uncomment it
//        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .autoSyncStatusDidChange, object: self)
//        }
    }
    
    
    // MARK: - Override me
    
    func itemsSortedToUpload(completion: @escaping WrapObjectsCallBack) {}

}
