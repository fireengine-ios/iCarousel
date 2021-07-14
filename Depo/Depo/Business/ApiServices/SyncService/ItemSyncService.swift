//
//  ItemSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

protocol ItemSyncService: AnyObject {
    var status: AutoSyncStatus { get }

    var delegate: ItemSyncServiceDelegate? { get set }

    func start(newItems: Bool)
    func stop()
    func fail()
    func waitForWiFi()
}


protocol ItemSyncServiceDelegate: AnyObject {
    func didReceiveOutOfSpaceError()
    func didReceiveError()
}


class ItemSyncServiceImpl: ItemSyncService {
    
    let mediaItemOperationsService = MediaItemOperationsService.shared
    
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
    private let uploadService = UploadService.default
    
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
            status = .stopped
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
                self.status = .stopped
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
            debugLog("ItemSyncServiceImpl isContained")
            return
        }
        
        status = .prepairing
        
        localItems.removeAll()
        itemsSortedToUpload { [weak self] items in

            guard let self = self else {
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

        guard !items.isEmpty, status != .stopped else {
            debugLog("ItemSyncServiceImpl status != .stoped")
            return
        }
        
        uploadService.uploadFileList(items: items,
                                             uploadType: .autoSync,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             success: { [weak self] in
                                                if self?.status == .executing {
                                                    self?.status = .synced
                                                }
        }, fail: { [weak self] error in
            
            guard let self = self else {
                debugLog("ItemSyncServiceImpl self == nil")
                print("\(#function): self == nil")
                return
            }
            
            if error.description == TextConstants.canceledOperationTextError || error.description == TextConstants.networkConnectionLostTextError {
                debugLog("ItemSyncServiceImpl \(error.description)")
                return
            }
            
            if error.isOutOfSpaceError {
                self.delegate?.didReceiveOutOfSpaceError()
            } else {
                self.delegate?.didReceiveError()
            }
            
            /// do not stop whole autosync if one error is received
//            self.fail()
            
            }, returnedUploadOperation: { [weak self] operations in
                guard self?.status != .executing else {
                    /// status == .executing
                    /// means that uploading is already in progress and we've just appended new items
                    debugLog("returnedUploadOperation already executing")
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
            guard let self = self else {
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
