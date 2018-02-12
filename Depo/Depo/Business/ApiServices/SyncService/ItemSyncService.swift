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
    var status: AutoSyncStatus {get}
    weak var delegate: ItemSyncServiceDelegate? {get set}
    
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
    private var dispatchQueue = DispatchQueue(label: "com.lifebox.autosync")
    
    var fileType: FileType = .unknown
    var status: AutoSyncStatus = .undetermined {
        didSet {
            debugPrint("AUTOSYNC: \(fileType) status = \(status)")
            if oldValue != status {
                postNotification()
            }
        }
    }
    
    var localItems: [WrapData] = []
    var localItemsMD5s: [String] = []
    var lastSyncedMD5s: [String] = []
    
    weak var delegate: ItemSyncServiceDelegate?
    
    
    //MARK: - Public ItemSyncService functions
    
    func start(newItems: Bool) {
        log.debug("ItemSyncServiceImpl start")
        dispatchQueue.async {
            guard !(newItems && self.status.isContained(in: [.prepairing, .executing])) else {
                self.appendNewUnsyncedItems()
                return
            }
            
            self.sync()
        }
    }
    
    func stop() {
        log.debug("ItemSyncServiceImpl stop")
        lastSyncedMD5s.removeAll()
        status = .stoped
    }
    
    func waitForWiFi() {
        log.debug("ItemSyncServiceImpl waitForWiFi")
        lastSyncedMD5s.removeAll()
        status = .waitingForWifi
    }
    
    func fail() {
        log.debug("ItemSyncServiceImpl fail")
        lastSyncedMD5s.removeAll()
        status = .failed
    }
    
    //MARK: - Private
    
    private func sync() {
        log.debug("ItemSyncServiceImpl sync")

        guard !status.isContained(in: [.executing, .prepairing]) else {
            return
        }
        
        status = .prepairing
        
        localItems.removeAll()
        localItems = self.itemsSortedToUpload()
        lastSyncedMD5s = self.localItems.map({ $0.md5 })
        
        guard !localItems.isEmpty else {
            status = .synced
            return
        }
        
        upload(items: self.localItems)
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
        }, fail: { [weak self] (error) in
            guard let `self` = self else {
                print("\(#function): self == nil")
                return
            }
            
            log.debug("ItemSyncServiceImpl upload UploadService uploadFileList fail")
            
            if error.description == TextConstants.canceledOperationTextError || error.description == TextConstants.networkConnectionLostTextError {
                return
            }
            
            if case ErrorResponse.httpCode(413) = error {
                self.delegate?.didReceiveOutOfSpaceError()
            } else {
                self.delegate?.didReceiveError()
            }
            
            self.fail()
            
        })
        
    }
    
    private func appendNewUnsyncedItems() {
        let group = DispatchGroup()
        var localUnsynced = [WrapData]()
        
        group.enter()
        DispatchQueue.main.async {
            localUnsynced = self.itemsSortedToUpload()
            group.leave()
        }
    
        group.notify(queue: dispatchQueue) {
            let newUnsyncedLocalItems = localUnsynced.filter({ !self.lastSyncedMD5s.contains($0.md5) })
            
            guard !newUnsyncedLocalItems.isEmpty else {
                return
            }
            
            self.upload(items: newUnsyncedLocalItems)
        }
    }
    
    private func postNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: autoSyncStatusDidChangeNotification, object: self)
        }
    }
    
    
    //MARK: - Override me
    
    func itemsSortedToUpload() -> [WrapData] {
        return []
    }

}



extension CoreDataStack {
    func getLocalUnsynced(fieldValue: FieldValue) -> [WrapData] {
        var itemsToReturn = [WrapData]()
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            let localItems = self.allLocalItemsForSync(video: fieldValue == .video, image: fieldValue == .image)
            
            let service = PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest, type: fieldValue)
            
            let queue = DispatchQueue(label: "com.lifebox.CoreDataStack")
            queue.async {
                self.compareRemoteItems(with: localItems, service: service, fieldValue: fieldValue) { (items, error) in
                    guard error == nil, let unsyncedItems = items else {
                        semaphore.signal()
                        return
                    }
                    
                    itemsToReturn = unsyncedItems
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
        
        return itemsToReturn
    }
    
    private func compareRemoteItems(with localItems: [WrapData], service: PhotoAndVideoService, fieldValue: FieldValue, handler:  @escaping (_ items: [WrapData]?, _ error: ErrorResponse?)->() ) {
        guard let oldestItemDate = localItems.last?.metaDate else {
            handler([], nil)
            return
        }
        
        var localItems = localItems
        var localMd5s = localItems.map { $0.md5 }
        
        var finished = false
        service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] (items) in
            guard let `self` = self else {
                //TODO: Error handling
                handler(nil, ErrorResponse.string("SelfNil") )
                return
            }
            
            for item in items {
                if item.metaDate < oldestItemDate {
                    finished = true
                    break
                }
                
                let serverObjectMD5 = item.md5
                if let index = localMd5s.index(of: serverObjectMD5) {
                    let localItem = localItems[index]
                    localItem.syncStatuses.append(SingletonStorage.shared.unigueUserID)
                    self.updateLocalItemSyncStatus(item: localItem)
                    
                    localItems.remove(at: index)
                    localMd5s.remove(at: index)
                    
                    if localItems.isEmpty {
                        finished = true
                        break
                    }
                }
            }
            
            if !finished, items.count == NumericConstants.numberOfElementsInSyncRequest {
                self.compareRemoteItems(with: localItems, service: service, fieldValue: fieldValue, handler: handler)
            } else {
                handler(localItems, nil)
            }
            }, fail: {
                //TODO: Error handling
                handler(nil, ErrorResponse.string("RequestError"))
        }, newFieldValue: fieldValue)
    }
}




