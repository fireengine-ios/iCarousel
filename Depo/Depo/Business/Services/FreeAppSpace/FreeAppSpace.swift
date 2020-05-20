//
//  FreeAppSpace.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FreeAppSpace: NSObject {
    
    enum State {
        case initial
        case processing
        case finished
    }
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let cacheManager = CacheManager.shared
//    FIXME: currently we had floating problem when we saw items from previos account and also cache manger delegate currently is setuping on lazy var. So temporal solution is to use Seesion Singleton that we set to nil on logout.
//    static let `default` = FreeAppSpace()
    private static var instance: FreeAppSpace?
    static var session: FreeAppSpace {
        if let instance = instance {
            return instance
        } else {
            let newInstance = FreeAppSpace()
            newInstance.cacheManager.delegates.add(newInstance)
            instance = newInstance
            return newInstance
        }
    }
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.freeAppSpace, attributes: .concurrent)
    
    private(set) var state = State.initial
    private var needSearchAgain = false
    
    private var duplicatesArray = SynchronizedArray<WrapData>()
    var duplicateObjects: [WrapData] {
        duplicatesArray.getArray()
    }
    
    var isEmptyDuplicates: Bool {
        duplicatesArray.isEmpty
    }
    
    //MARK: -
    
    deinit {
        cacheManager.delegates.remove(self)
        ItemOperationManager.default.stopUpdateView(view: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func checkFreeUpSpace() {
        guard cacheManager.isCacheActualized else {
            return
        }
        
        onDatabasePrepareComplete()
    }
   
    func clear() {
        duplicatesArray.removeAll()
        state = .initial
    }
    
    func handleLogout() {
        FreeAppSpace.instance = nil
    }
    
    func checkFreeUpSpaceAfterAutoSync() {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            if self.state == .processing {
                self.needSearchAgain = true
                return
            }
            
            if self.duplicatesArray.isEmpty {
                self.checkFreeUpSpace()
            } else {
                self.updateFreeUpSpaceCard()
            }
        }
    }
    
    func showFreeUpSpaceCard() {
        CardsManager.default.startOperationWith(type: .freeAppSpace)
    }

    func updateFreeUpSpaceCard() {
        if !isEmptyDuplicates, Device.getFreeDiskSpaceInPercent < NumericConstants.freeAppSpaceLimit {
            CardsManager.default.stopOperationWith(type: .freeAppSpace)
            CardsManager.default.startOperationWith(type: .freeAppSpaceLocalWarning)
        } else {
            CardsManager.default.stopOperationWith(type: .freeAppSpaceLocalWarning)
            CardsManager.default.startOperationWith(type: .freeAppSpace)
        }
    }
    
    // MARK: - Private methods

    private func startSearchDuplicates(finished: @escaping VoidHandler) {
        if state == .processing {
            needSearchAgain = true
            return
        }
        
        state = .processing
        
        DispatchQueue.main.async {
            ItemOperationManager.default.startUpdateView(view: self)
        }

        duplicatesArray.removeAll()
        
        getDuplicatesItems { [weak self] items in
            guard let self = self else {
                return
            }
            
            self.duplicatesArray.append(items)
            if self.duplicatesArray.isEmpty {
                debugPrint("have no duplicates")
            } else {
                debugPrint("duplicates count = ", self.duplicatesArray.count)
            }
            self.state = .finished
            finished()
        }
    }
    
    private func onDatabasePrepareComplete() {
        dispatchQueue.async { [weak self] in
            self?.startSearchDuplicates(finished: { [weak self] in
                guard let self = self else {
                    return
                }
                
                if self.needSearchAgain {
                    self.needSearchAgain = false
                    self.checkFreeUpSpace()
                    return
                }
                
                self.sortDuplicatesArray()
                
                self.updateFreeUpSpaceCard()
            })
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
    
    fileprivate func getDuplicatesItems(_ localItemsCallback: @escaping WrapObjectsCallBack) {
        ///For now changed to get info from DB every time we enter FreeUP screen
        //TODO: optimize this class
            MediaItemOperationsService.shared.getLocalDuplicates { localItems in
                localItemsCallback(localItems.map { WrapData(mediaItem: $0)}.sorted(by: {
                    $0.metaDate > $1.metaDate
                }) )
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
            
            if self.state == .processing {
                self.needSearchAgain = true
                return
            }
            
            if !self.duplicatesArray.contains(duplicate) {
                self.duplicatesArray.append(duplicate)
            }
            
            self.sortDuplicatesArray()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateFreeUpSpaceCard()
            }
        }
    }
    
    func finishedDownloadFile(file: WrapData) {
        guard !file.isLocalItem else {
            return
        }

        MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: [file]) { [weak self] items in
            self?.dispatchQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                items.forEach({ item in
                    if !self.duplicatesArray.contains(item) {
                        self.duplicatesArray.append(item)
                    }
                })

                self.sortDuplicatesArray()
                self.checkFreeUpSpaceAfterAutoSync()
            }
        }
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        deleteItems(items: items)
    }
    
    func deleteItems(items: [Item]) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let remoteItems = items.filter {!$0.isLocalItem}
            let localItems = items.filter {$0.isLocalItem}

            if !localItems.isEmpty {
                localItems.forEach { self.duplicatesArray.removeIfExists($0) }
            }

            if !remoteItems.isEmpty {
                let uuids = remoteItems.map {$0.getTrimmedLocalID()}
                self.duplicatesArray.remove(where: { uuids.contains($0.getTrimmedLocalID()) }, completion: nil)
            }
            
            self.updateFreeUpSpaceCard()
        }
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return object === self
    }
}

// MARK: - CacheManagerDelegate

extension FreeAppSpace: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        onDatabasePrepareComplete()
    }
}

// MARK: - FreeAppService

final class FreeAppService: RemoteItemsService {

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
            FreeAppSpace.session.getDuplicatesItems { array in
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
