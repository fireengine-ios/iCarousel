//
//  FreeAppSpace.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FreeAppSpace: NSObject {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var cacheManager: CacheManager = {
        let manager = CacheManager.shared
        manager.delegates.add(self)
        return manager
    }()
    
    static let `default` = FreeAppSpace()
    
    private var isSearchRunning = false
    private var needSearchAgain = false
    
    private var duplicatesArray = SynchronizedArray<WrapData>()
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.freeAppSpace, attributes: .concurrent)
    
    //MARK: -
    
    deinit {
        cacheManager.delegates.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func getDuplicatesObjects() -> [WrapData] {
        return duplicatesArray.getArray()
    }
    
    func getDuplicatesItems(_ localItemsCallback: @escaping WrapObjectsCallBack) {
        if duplicatesArray.isEmpty {
            MediaItemOperationsService.shared.getLocalDuplicates { localItems in
                localItemsCallback(localItems.map { WrapData(mediaItem: $0)} )
            }
        } else {
            localItemsCallback(getDuplicatesObjects())
        }
    }
    
    func checkFreeAppSpace() {
        guard cacheManager.isCacheActualized else {
            return
        }
        
        onDatabasePrepareComplete()
    }
   
    func clear() {
        duplicatesArray.removeAll()
        isSearchRunning = false
    }
    
    func checkFreeAppSpaceAfterAutoSync() {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.isSearchRunning {
                self.needSearchAgain = true
                return
            }
            
            if self.duplicatesArray.isEmpty {
                self.checkFreeAppSpace()
            } else {
                self.showFreeAppSpaceCard()
            }
        }
    }
    
    private func sortDuplicatesArray() {
        ///sort itself, or remove all and appen new elements
        duplicatesArray.sortItself(by: { obj1, obj2 -> Bool in
            if let date1 = obj1.creationDate, let date2 = obj2.creationDate, date1 > date2 {
                return true
            }
            return false
        })
    }
    
    private func showFreeAppSpaceCard() {
        if !duplicatesArray.isEmpty {
            let freeSpace = Device.getFreeDiskSpaceInPercent
            if freeSpace < NumericConstants.freeAppSpaceLimit {
                CardsManager.default.startOperationWith(type: .freeAppSpaceLocalWarning, allOperations: nil, completedOperations: nil)
            } else {
                CardsManager.default.startOperationWith(type: .freeAppSpace, allOperations: nil, completedOperations: nil)
            }
        } else {
            print("have no duplicates")
        }
    }
    
     private func onDatabasePrepareComplete() {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.startSearchDuplicates(finished: { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.isSearchRunning = false
                
                if self.needSearchAgain {
                    self.needSearchAgain = false
                    self.checkFreeAppSpace()
                    return
                }
                
                self.sortDuplicatesArray()
                
                self.showFreeAppSpaceCard()
            })
        }
    }
    
    func startSearchDuplicates(finished: @escaping VoidHandler) {
        if isSearchRunning {
            needSearchAgain = true
            return
        }
        
        isSearchRunning = true
        
        ItemOperationManager.default.startUpdateView(view: self)

        duplicatesArray.removeAll()
        
        getDuplicatesItems { [weak self] items in
            guard let `self` = self else {
                return
            }
            
            self.duplicatesArray.append(items)
            if self.duplicatesArray.isEmpty {
                debugPrint("have no duplicates")
            } else {
                debugPrint("duplicates count = ", self.duplicatesArray.count)
            }
            finished()
        }
    }
}

// MARK: - ItemOperationManagerViewProtocol

extension FreeAppSpace: ItemOperationManagerViewProtocol {
    func finishedUploadFile(file: WrapData) {
        MediaItemOperationsService.shared.allLocalItems(trimmedLocalIds: [file.getTrimmedLocalID()]) { [weak self] localDuplicates in
            
            /// must be only one local duplicate for one remote
            guard let self = self, let duplicate = localDuplicates.first else {
                return
            }
            
            print("uploaded object with uuid - ", duplicate.uuid)
            
            if self.isSearchRunning {
                self.needSearchAgain = true
                return
            }
            
            if !self.duplicatesArray.contains(duplicate) {
                self.duplicatesArray.append(duplicate)
            }
            
            self.sortDuplicatesArray()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showFreeAppSpaceCard()
            }
        }
    }
    
    func finishedDownloadFile(file: WrapData) {
        guard !file.isLocalItem else {
            return
        }

        MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: [file]) { [weak self] items in
            self?.dispatchQueue.async {
                guard let `self` = self else {
                    return
                }
                
                items.forEach({ item in
                    if !self.duplicatesArray.contains(item) {
                        self.duplicatesArray.append(item)
                    }
                })

                self.sortDuplicatesArray()
                self.checkFreeAppSpaceAfterAutoSync()
            }
        }
    }
    
    func deleteItems(items: [Item]) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let remoteItems = items.filter {!$0.isLocalItem}
            let localItems = items.filter {$0.isLocalItem}

            if !localItems.isEmpty {
                localItems.forEach { item in
                    self.duplicatesArray.removeIfExists(item)
                }
            }

            if !remoteItems.isEmpty {
                let uuids = remoteItems.map {$0.getTrimmedLocalID()}
                self.duplicatesArray.remove(where: { uuids.contains($0.getTrimmedLocalID()) }, completion: nil)
            }
            
            if self.duplicatesArray.isEmpty {
                CardsManager.default.stopOperationWithType(type: .freeAppSpace)
                CardsManager.default.stopOperationWithType(type: .freeAppSpaceLocalWarning)
            }
        }
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? FreeAppSpace {
            return compairedView == self
        }
        return false
    }
    
}

class FreeAppService: RemoteItemsService {

    /// server request don't have pagination
    /// but we need this logic for the same logic
    private var isGotAll = false

    init() {
        super.init(requestSize: 9999, fieldValue: .audio)
    }

    func allItems(success: ListRemoteItems?, fail: FailRemoteItems?) {
        if self.isGotAll {
            success?([])
            return
        } else {
            isGotAll = true
            FreeAppSpace.default.getDuplicatesItems { array in
                success?(array)
            }
        }
    }

    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        allItems(success: success, fail: fail)
    }

    func clear() {
        isGotAll = false
    }
}

extension FreeAppSpace: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        onDatabasePrepareComplete()
    }
}
