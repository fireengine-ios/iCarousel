//
//  LocalUnsyncedOperation.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 5/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LocalUnsyncedOperation: Operation {
    
    typealias UnsyncedItemsCompletion = ([WrapData]) -> Void
    
    
    private let service: PhotoAndVideoService
    private let fieldValue: FieldValue
    private let completion: UnsyncedItemsCompletion
    
    private let coreDataStack = CoreDataStack.default
    private let semaphore = DispatchSemaphore(value: 0)
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.localUnsyncedOperationQueue)
    
    
    init(service: PhotoAndVideoService, fieldValue: FieldValue, completion: @escaping UnsyncedItemsCompletion) {
        self.service = service
        self.fieldValue = fieldValue
        self.completion = completion
    }
    
    override func cancel() {
        super.cancel()
        
        service.stopAllOperations()
        completion([])
        semaphore.signal()
    }
    
    override func main() {
        coreDataStack.allLocalItemsForSync(video: fieldValue == .video, image: fieldValue == .image, completion: { [weak self] items in
            
            guard let `self` = self else {
                return
            }
            
            guard self.isExecuting else {
                self.completion([])
                self.semaphore.signal()
                return
            }
            
            self.compareRemoteItems(with: items, service: self.service, fieldValue: self.fieldValue) { [weak self] items, error in
                guard let `self` = self else {
                    return
                }
                
                guard error == nil, let unsyncedItems = items, self.isExecuting else {
                    self.completion([])
                    self.semaphore.signal()
                    return
                }
                
                self.completion(unsyncedItems)
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
