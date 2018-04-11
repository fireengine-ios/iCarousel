//
//  FreeAppSpace.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpace: NSObject, ItemOperationManagerViewProtocol {
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    static let `default` = FreeAppSpace()
    
    private var photoVideoService: PhotoAndVideoService?
    private var isSearchRunning = false
    private var needSearchAgain = false
    private let numberElementsInRequest = 50000
    
    private var localtemsArray = [WrapData]()
    private var localMD5Array = [String]()
    private var duplicatesArray = [WrapData]()
    private var serverDuplicatesArray = [WrapData]()
    
    func getDuplicatesObjects() -> [WrapData] {
        return duplicatesArray
    }
    
    func getCheckedDuplicatesArray(checkedArray: @escaping([WrapData]) -> Void) {
//        DispatchQueue.main.async {[weak self] in
//            if let `self` = self {
        CoreDataStack.default.getLocalDuplicates(remoteItems: self.getDuplicatesObjects(), duplicatesCallBack: { [weak self] items in
            guard let `self` = self else {
                checkedArray([])
                return
            }
            self.duplicatesArray.removeAll()
            self.duplicatesArray.append(contentsOf: items)
            self.sortDuplicatesArray()
            checkedArray(self.duplicatesArray)
        })
        
//            }
//        }
    }
    
    func clear() {
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        duplicatesArray.removeAll()
        serverDuplicatesArray.removeAll()
        isSearchRunning = false
        if let service = photoVideoService {
            service.stopAllOperations()
            photoVideoService = nil
        }
    }
    
    func getUIDSForObjects(itemsArray: [BaseDataSourceItem]) -> [String] {
        let serverHash = serverDuplicatesArray.map { $0.md5 }
        var array = [String]()
        for item in itemsArray {
            let index = serverHash.index(of: item.md5)
            if let index_ = index {
                let serverObject = serverDuplicatesArray[index_]
                array.append(serverObject.uuid)
            } else {
                array.append(item.uuid)
            }
        }
        return array
    }
    
    func checkFreeAppSpaceAfterAutoSync() {
        if (isSearchRunning) {
            needSearchAgain = true
            return
        }
        
        if duplicatesArray.count > 0 {
            showFreeAppSpaceCard()
        } else {
            checkFreeAppSpace()
        }
        
    }
    
    func sortDuplicatesArray() {
        duplicatesArray = duplicatesArray.sorted(by: { obj1, obj2 -> Bool in
            if let date1 = obj1.creationDate, let date2 = obj2.creationDate, date1 > date2 {
                return true
            }
            return false
        })
    }
    
    func checkFreeAppSpace() {
        if tokenStorage.refreshToken == nil {
            return
        }
        photoVideoService?.currentPage = 0
        startSearchDuplicates(finished: { [weak self] in
            guard let self_ = self else {
                return
            }
            
            self_.isSearchRunning = false
            
            if (self_.needSearchAgain) {
                self_.needSearchAgain = false
                self_.checkFreeAppSpace()
                return
            }
            
            self_.sortDuplicatesArray()
            
            self_.showFreeAppSpaceCard()
        })
    }
    
    func showFreeAppSpaceCard() {
        if (duplicatesArray.count > 0) {
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
    
    func deleteDeletedLocalPhotos(deletedPhotos: [WrapData]) {
        for object in deletedPhotos {
            if let index = duplicatesArray.index(of: object) {
                duplicatesArray.remove(at: index)
                analyticsService.track(event: .freeUpSpace)
            }
        }
    }
    
    func startSearchDuplicates(finished: @escaping() -> Void) {
        if (isSearchRunning) {
            needSearchAgain = true
            return
        }
        
        isSearchRunning = true
        
        ItemOperationManager.default.startUpdateView(view: self)
        
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        duplicatesArray.removeAll()
        serverDuplicatesArray.removeAll()
        
//        DispatchQueue.main.async {
            self.localtemsArray.append(contentsOf: self.allLocalItems().sorted { item1, item2 -> Bool in
                if let date1 = item1.creationDate, let date2 = item2.creationDate {
                    if (date1 > date2) {
                        return true
                    }
                }
                return false
            })
            
            self.localMD5Array.append(contentsOf: self.localtemsArray.map({ $0.md5 }))
            let latestDate = self.localtemsArray.last?.creationDate ?? Date()
            
            //need to check have we duplicates
            if self.localtemsArray.count > 0 {
                self.photoVideoService = PhotoAndVideoService(requestSize: self.numberElementsInRequest)
                self.getDuplicatesObjects(latestDate: latestDate, success: { [weak self] in
                    guard let self_ = self else {
                        return
                    }
                    if (self_.duplicatesArray.count > 0) {
                        debugPrint("duplicates count = ", self_.duplicatesArray.count)
                    } else {
                        debugPrint("have no duplicates")
                    }
                    finished()
                    }, fail: {
                        finished()
                })
            } else {
                finished()
            }
//        }
        
    }
    
    private func getDuplicatesObjects(latestDate: Date,
                                      success: @escaping ()-> Void,
                                      fail: @escaping ()-> Void) {

        guard let service = self.photoVideoService else {
            fail()
            return
        }
        var finished = false
        
        service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] items in
            guard let self_ = self else {
                fail()
                return
            }
            
            for item in items {
                if let date = item.creationDate, date < latestDate {
                    finished = true
                    break
                }
                let index = self_.localMD5Array.index(of: item.md5)
                if let index_ = index {
                    self_.serverDuplicatesArray.append(item)
                    self_.duplicatesArray.append(self_.localtemsArray[index_])
                    self_.localtemsArray.remove(at: index_)
                    self_.localMD5Array.remove(at: index_)
                    
                    if (self_.localtemsArray.count == 0) {
                        finished = true
                        break
                    }
                }
            }
            
            if (!finished) && (items.count == self_.numberElementsInRequest) {
                self_.getDuplicatesObjects(latestDate: latestDate, success: success, fail: fail)
            } else {
                success()
            }
        }, fail: {
            fail()
        }, newFieldValue: nil)
    }
    
    private func allLocalItems() -> [WrapData] {
        return CoreDataStack.default.allLocalItems()
    }
    
    func getLocalFiesComaredWithServerObjects(serverObjects: [WrapData], localObjects: [WrapData]) -> [WrapData] {
        var comparedFiles = [WrapData]()
        
        let serverObjectMD5Array = serverObjects.map { $0.md5 }
        for localObject in localObjects {
            if serverObjectMD5Array.index(of: localObject.md5) != nil {
                comparedFiles.append(localObject)
            }
        }
        
        return comparedFiles
    }
    
    // MARK: UploadNotificationManagerProtocol
    
    func finishedUploadFile(file: WrapData) {
        print("uploaded object with uuid - ", file.uuid)
        if (isSearchRunning) {
            needSearchAgain = true
            return
        }
        
        if file.isLocalItem {
            if localMD5Array.index(of: file.md5) == nil {
                file.metaData?.takenDate = Date()
                localMD5Array.append(file.md5)
            }
            duplicatesArray.append(file)
        } else {
            print("uploaded server object")
            let serverObjectsUUIDs = serverDuplicatesArray.map({ $0.uuid })
            if !serverObjectsUUIDs.contains(file.uuid) {
                serverDuplicatesArray.append(file)
            }
                
            let fetchRequest = NSFetchRequest<MediaItem>(entityName: "MediaItem")
            let predicate = PredicateRules().allLocalObjectsForObjects(objects: [file])
            let sortDescriptors = CollectionSortingRules(sortingRules: .timeUp).rule.sortDescriptors
            
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            
            let context = CoreDataStack.default.newChildBackgroundContext
            guard let fetchResult = try? context.fetch(fetchRequest) else {
                return
            }
            //
            debugPrint("!!!!!! perform in context ???")
            //
            let localObjects = fetchResult.map { WrapData(mediaItem: $0) }
            for localObject in localObjects {
                if localMD5Array.index(of: localObject.md5) == nil {
                    file.metaData?.takenDate = Date()
                    localMD5Array.append(localObject.md5)
                }
                duplicatesArray.append(localObject)
            }
            
        }
        
        sortDuplicatesArray()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showFreeAppSpaceCard()
        }
    }
    
    func finishedDownloadFile(file: WrapData) {
        if !file.isLocalItem {
            CoreDataStack.default.getLocalDuplicates(remoteItems: [file], duplicatesCallBack: { [weak self] items in
                guard let `self` = self else {
                    return
                }
                if !items.isEmpty {
                    for localObject in items {
                        if self.localMD5Array.index(of: localObject.md5) == nil {
                            file.metaData?.takenDate = Date()
                            self.duplicatesArray.append(localObject)
                            self.localMD5Array.append(localObject.md5)
                        }
                    }
                    self.sortDuplicatesArray()
                }
               self.checkFreeAppSpaceAfterAutoSync()
                
            })
            
        }
    }
    
    func addedLocalFiles(items: [Item]) {

        let serverObjectsUUIDs = serverDuplicatesArray.map({ $0.uuid })

        for item in items {
            if serverObjectsUUIDs.contains(item.uuid) {
                localtemsArray.append(item)
                duplicatesArray.append(item)
            }
        }
    }
    
    func deleteItems(items: [Item]) {
        SyncedBlock.synced(self) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                if (self.isSearchRunning) {
                    self.needSearchAgain = true
                    return
                }
                
                var localObjects = items.filter {
                    $0.isLocalItem
                }
                
                var newDuplicatesArray = [WrapData]()
                let duplicatesMD5Set = Set<String>(localObjects.map({ $0.md5 }))
                for object in self.duplicatesArray {
                    if !duplicatesMD5Set.contains(object.md5) {
                        newDuplicatesArray.append(object)
                    }
                }
                self.duplicatesArray = newDuplicatesArray
                
                let networksObjects = items.filter {
                    !$0.isLocalItem
                }
                
                CoreDataStack.default.getLocalDuplicates(remoteItems: networksObjects, duplicatesCallBack: { [weak self] items in
                    guard let `self` = self else {
                        return
                    }
                    let duplicatesServerMD5Set = Set<String>(items.map({ $0.md5 }))
                    newDuplicatesArray.removeAll()
                    for object in self.duplicatesArray {
                        if !duplicatesServerMD5Set.contains(object.md5) {
                            newDuplicatesArray.append(object)
                        }
                    }
                    self.duplicatesArray = newDuplicatesArray
                    
                    if (self.duplicatesArray.count == 0) {
                        CardsManager.default.stopOperationWithType(type: .freeAppSpace)
                        CardsManager.default.stopOperationWithType(type: .freeAppSpaceLocalWarning)
                    }
                })
                
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
    
    func allItems(success: ListRemoveItems?, fail: FailRemoteItems?) {

        if self.isGotAll {
            success?([])
            return
        } else {
            isGotAll = true
            FreeAppSpace.default.getCheckedDuplicatesArray(checkedArray: { array in
                success?(array)
            })
        }
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        allItems(success: success, fail: fail)
    }
    
    func clear() {
        isGotAll = false
    }
}
