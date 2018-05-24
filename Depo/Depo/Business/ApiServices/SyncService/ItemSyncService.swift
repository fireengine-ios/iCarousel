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
    
    var photoVideoService: PhotoAndVideoService {
        let fieldValue: FieldValue = (fileType == .image) ? .image : .video
        return PhotoAndVideoService(requestSize: NumericConstants.numberOfElementsInSyncRequest, type: fieldValue)
    }
    
    var getUnsyncedOperationQueue = OperationQueue()
    
    weak var delegate: ItemSyncServiceDelegate?
    
    
    // MARK: - Public ItemSyncService functions
    
    func start(newItems: Bool) {
        log.debug("ItemSyncServiceImpl start")
        
        guard !CoreDataStack.default.inProcessAppendingLocalFiles else {
            /// don't need to change status because it's fake preparation until CoreData processing is done
            CardsManager.default.startOperationWith(type: .prepareToAutoSync, allOperations: nil, completedOperations: nil)
            return
        }
        
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
            self?.status = hasItemsToSync ? .waitingForWifi : .stoped
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
            
            }, returnedUploadOperation: { [weak self] operations in
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .autoSyncStatusDidChange, object: self)
        }
    }
    
    
    // MARK: - Override me
    
    func itemsSortedToUpload(completion: @escaping (_ items: [WrapData]) -> Void) {}

}

final class GetLocalUnsyncedOperation: Operation {
    
    typealias UnsyncedItemsCompletion = ([WrapData]) -> Void
    
    
    private var service: PhotoAndVideoService?
    private var fieldValue: FieldValue?
    private var completion: UnsyncedItemsCompletion?
    
    private let coreDataStack = CoreDataStack.default
    private let semaphore = DispatchSemaphore(value: 0)
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.privateConcurentQueue)
    
    
    init(service: PhotoAndVideoService, fieldValue: FieldValue, completion: @escaping UnsyncedItemsCompletion) {
        self.service = service
        self.fieldValue = fieldValue
        self.completion = completion
    }
    
    override func cancel() {
        super.cancel()
        
        service?.stopAllOperations()
        
        completion?([])
        semaphore.signal()
    }
    
    override func main() {
        guard let field = fieldValue, let service = service, let completion = completion else {
            return
        }
        
        coreDataStack.allLocalItemsForSync(video: field == .video, image: field == .image, completion: { [weak self] items in
            guard let `self` = self, self.isExecuting else {
                return
            }
            
            self.compareRemoteItems(with: items, service: service, fieldValue: field) { [weak self] items, error in
                guard let `self` = self else {
                    return
                }
                
                guard error == nil, let unsyncedItems = items, self.isExecuting else {
                    completion([])
                    self.semaphore.signal()
                    return
                }
                
                completion(unsyncedItems)
                self.semaphore.signal()
            }
        })
        
        semaphore.wait()
    }
    
    private func compareRemoteItems(with localItems: [WrapData], service: PhotoAndVideoService, fieldValue: FieldValue, handler:  @escaping (_ items: [WrapData]?, _ error: ErrorResponse?) -> Void ) {
        privateQueue.async {
            let sortedByDateItems = localItems.sorted { $0.metaDate > $1.metaDate }
            guard let oldestItemDate = sortedByDateItems.last?.metaDate else {
                handler([], nil)
                return
            }
            log.debug("LocalMediaStorage compareRemoteItems")
            var localItems = localItems
            var localMd5s = localItems.map { $0.md5 }
            var localIds = localItems.map { $0.getTrimmedLocalID() }
            
            var finished = false
            service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] items in
                self?.privateQueue.async { [weak self] in
                    guard let `self` = self else {
                        handler(nil, ErrorResponse.string(TextConstants.commonServiceError))
                        return
                    }
                    
                    finished = (items.count < NumericConstants.numberOfElementsInSyncRequest)
                    
                    for item in items {
                        if item.metaDate < oldestItemDate {
                            finished = true
                            break
                        }
                        
                        let serverObjectMD5 = item.md5
                        let trimmedId = item.getTrimmedLocalID()
                        if let index = localMd5s.index(of: serverObjectMD5) ?? localIds.index(where: { $0 == trimmedId }) {
                            let localItem = localItems[index]
                            localItem.setSyncStatusesAsSyncedForCurrentUser()
                            self.coreDataStack.updateLocalItemSyncStatus(item: localItem)
                            
                            localItems.remove(at: index)
                            localMd5s.remove(at: index)
                            localIds.remove(at: index)
                            
                            if localItems.isEmpty {
                                finished = true
                                break
                            }
                        }
                    }
                    
                    if !finished {
                        self.compareRemoteItems(with: localItems, service: service, fieldValue: fieldValue, handler: handler)
                    } else {
                        handler(localItems, nil)
                    }
                }
                }, fail: {
                    handler(nil, ErrorResponse.string(TextConstants.commonServiceError))
            }, newFieldValue: fieldValue)
        }
    }
}

