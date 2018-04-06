//
//  ItemSyncService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/14/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


public let autoSyncStatusDidChangeNotification = NSNotification.Name("AutoSyncStatusChangedNotification")

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
    
    var photoVideoService: PhotoAndVideoService {
        let fieldValue: FieldValue = (fileType == .image) ? .image : .video
        return PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest, type: fieldValue)
    }
    
    weak var delegate: ItemSyncServiceDelegate?
    
    
    // MARK: - Public ItemSyncService functions
    
    func start(newItems: Bool) {
        log.debug("ItemSyncServiceImpl start")
        
        guard !(newItems && status.isContained(in: [.prepairing, .executing])) else {
            appendNewUnsyncedItems()
            return
        }
        
        sync()
    }
    
    func stop() {
        log.debug("ItemSyncServiceImpl stop")
        
        lastSyncedMD5s.removeAll()
        if status != .synced {
            status = .stoped
        }
    }
    
    func waitForWiFi() {
        log.debug("ItemSyncServiceImpl waitForWiFi")
        
        lastSyncedMD5s.removeAll()
        
        CoreDataStack.default.hasLocalItemsForSync(video: fileType == .video, image: fileType == .image, completion: { [weak self] hasItemsToSync in
            if hasItemsToSync {
                self?.status = .waitingForWifi
            }
        })
        
       
    }
    
    func fail() {
        log.debug("ItemSyncServiceImpl fail")
        
        lastSyncedMD5s.removeAll()
        status = .failed
    }
    
    // MARK: - Private
    
    private func sync() {
        log.debug("ItemSyncServiceImpl sync")

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
        log.debug("ItemSyncServiceImpl upload")

        guard !items.isEmpty else {
            return
        }
        
        status = .executing
        
        UploadService.default.uploadFileList(items: items,
                                             uploadType: .autoSync,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             success: { [weak self] in
                                                log.debug("ItemSyncServiceImpl upload UploadService uploadFileList success")
                                                if self?.status == .executing {
                                                    self?.status = .synced
                                                }
        }, fail: { [weak self] error in
            guard let `self` = self else {
                print("\(#function): self == nil")
                return
            }
            
            log.debug("ItemSyncServiceImpl upload UploadService uploadFileList fail")
            
            if error.description == TextConstants.canceledOperationTextError || error.description == TextConstants.networkConnectionLostTextError {
                return
            }
            
            if error.isOutOfSpaceError {
                self.delegate?.didReceiveOutOfSpaceError()
            } else {
                self.delegate?.didReceiveError()
            }
            
            self.fail()
            
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: autoSyncStatusDidChangeNotification, object: self)
        }
    }
    
    
    // MARK: - Override me
    
    func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {}

}


extension CoreDataStack {
    func getLocalUnsynced(fieldValue: FieldValue, service: PhotoAndVideoService, completion: @escaping (_ items: [WrapData]) -> Void) {

        
        backgroundContext.perform { [weak self] in
            guard let `self` = self else {
                completion([])
                return
            }
            self.allLocalItemsForSync(video: fieldValue == .video, image: fieldValue == .image, completion: {[weak self] items in
                guard let `self` = self else {
                    completion([])
                    return
                }
                self.compareRemoteItems(with: items, service: service, fieldValue: fieldValue) { items, error in
                    guard error == nil, let unsyncedItems = items else {
                        print(error!.description)
                        completion([])
                        return
                    }
                }
            })
            
        }
        
    }
    
    private func compareRemoteItems(with localItems: [WrapData], service: PhotoAndVideoService, fieldValue: FieldValue, handler:  @escaping (_ items: [WrapData]?, _ error: ErrorResponse?) -> Void ) {
        guard let oldestItemDate = localItems.last?.metaDate else {
            handler([], nil)
            return
        }
        log.debug("LocalMediaStorage compareRemoteItems")
        var localItems = localItems
        var localMd5s = localItems.map { $0.md5 }
        
        var finished = false
        service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] items in
            guard let `self` = self else {
                handler(nil, ErrorResponse.string(TextConstants.commonServiceError))
                return
            }
            self.privateQueue.async { [weak self] in
                for item in items {
                    if item.metaDate < oldestItemDate {
                        finished = true
                        break
                    }
                    
                    let serverObjectMD5 = item.md5
                    if let index = localMd5s.index(of: serverObjectMD5) {
                        let localItem = localItems[index]
                        localItem.setSyncStatusesAsSyncedForCurrentUser()
                        self?.updateLocalItemSyncStatus(item: localItem)
                        
                        localItems.remove(at: index)
                        localMd5s.remove(at: index)
                        
                        if localItems.isEmpty {
                            finished = true
                            break
                        }
                    }
                }
                
                if !finished, items.count == NumericConstants.numberOfElementsInSyncRequest {
                    self?.compareRemoteItems(with: localItems, service: service, fieldValue: fieldValue, handler: handler)
                } else {
                    handler(localItems, nil)
                }
            }
            
            
            }, fail: {
                handler(nil, ErrorResponse.string(TextConstants.commonServiceError))
        }, newFieldValue: fieldValue)
    }
}
