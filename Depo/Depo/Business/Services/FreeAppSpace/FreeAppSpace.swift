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
    
    private var localtemsArray = SynchronizedArray<WrapData>()
    private var localMD5Array = SynchronizedArray<String>()
    private var duplicatesArray = SynchronizedArray<WrapData>()
    private var serverDuplicatesArray = SynchronizedArray<WrapData>()
    private var localTrimmedID = SynchronizedArray<String>()
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.freeAppSpace, attributes: .concurrent)

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getDuplicatesObjects() -> [WrapData] {
        return duplicatesArray.getArray()
    }
    
    func getCheckedDuplicatesArray(checkedArray: @escaping([WrapData]) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            CoreDataStack.default.getLocalDuplicates(remoteItems: self.getDuplicatesObjects(), duplicatesCallBack: { [weak self] items in
                self?.dispatchQueue.async { [weak self] in
                    guard let `self` = self else {
                        checkedArray([])
                        return
                    }
                    
                    var arrayForDisplay = [WrapData]()
                    
                    var localSet = Set<String>(items.map({ $0.md5 }))
                    var newDuplicates = [WrapData]()
                    self.duplicatesArray.forEach {
                        if localSet.contains($0.md5) {
                            newDuplicates.append($0)
                        }
                    }
                    
                    for item in self.duplicatesArray.getArray() {
                        if localSet.contains(item.md5){
                            if item.metaData?.takenDate == nil {
                                item.metaData?.takenDate = Date()
                            }
                            
                            arrayForDisplay.append(item)
                            localSet.remove(item.md5)
                        }
                    }
                    
                    self.duplicatesArray.removeAll()
                    self.duplicatesArray.append(newDuplicates)
                    
                    
                    
                    checkedArray(arrayForDisplay)
                }
            })
        }
    }
    
    func clear() {
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        localTrimmedID.removeAll()
        duplicatesArray.removeAll()
        serverDuplicatesArray.removeAll()
        isSearchRunning = false
        if let service = photoVideoService {
            service.stopAllOperations()
            photoVideoService = nil
        }
    }
    
    func getUIDSForObjects(itemsArray: [BaseDataSourceItem], uuidsCallback: @escaping ([String])->Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                uuidsCallback([])
                return
            }
            let serverHash = self.serverDuplicatesArray.flatMap { $0.md5 }
            let serverUUID = self.serverDuplicatesArray.flatMap{ $0.getTrimmedLocalID() }
            var array = [String]()
            
            for item in itemsArray {
                let index = serverHash.index(of: item.md5)
                if let index_ = index, let serverObject = self.serverDuplicatesArray[index_] {
                    array.append(serverObject.uuid)
                } else {
                    let index = serverUUID.index(of: item.getUUIDAsLocal())
                    if let index_ = index, let serverObject = self.serverDuplicatesArray[index_] {
                        array.append(serverObject.uuid)
                    } else {
                        array.append(item.uuid)
                    }
                }
            }
            uuidsCallback(array)
        }
    }
    
    func checkFreeAppSpaceAfterAutoSync() {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if (self.isSearchRunning) {
                self.needSearchAgain = true
                return
            }
            
            if self.duplicatesArray.count > 0 {
                self.showFreeAppSpaceCard()
            } else {
                self.checkFreeAppSpace()
            }
        }
    }
    
    func sortDuplicatesArray() {
        ///sort itself, or remove all and appen new elements
        duplicatesArray.sortItself(by: { obj1, obj2 -> Bool in
            if let date1 = obj1.creationDate, let date2 = obj2.creationDate, date1 > date2 {
                return true
            }
            return false
        })
    }
    
    func checkFreeAppSpace() {
        if CoreDataStack.default.inProcessAppendingLocalFiles {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onLocalFilesHaveBeenLoaded),
                                                   name: Notification.Name.allLocalMediaItemsHaveBeenLoaded,
                                                   object: nil)
        } else {
            onLocalFilesHaveBeenLoaded()
        }
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
    
    @objc private func onLocalFilesHaveBeenLoaded() {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.tokenStorage.refreshToken == nil {
                return
            }
            self.photoVideoService?.currentPage = 0
            self.startSearchDuplicates(finished: { [weak self] in
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
    }
    
    func deleteDeletedLocalPhotos(deletedPhotos: [WrapData]) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            for object in deletedPhotos {
                ///Previously it was compering pointers not md5 values
                if let index = self.duplicatesArray.index(where: { $0.md5 == object.md5 }) {
                    self.duplicatesArray.remove(at: index)
                    self.analyticsService.track(event: .freeUpSpace)
                } else if let index = self.duplicatesArray.index(where: { $0.getTrimmedLocalID() == object.getTrimmedLocalID() }) {
                    self.duplicatesArray.remove(at: index)
                    self.analyticsService.track(event: .freeUpSpace)
                }
            }
        }
    }
    
    func startSearchDuplicates(finished: @escaping VoidHandler) {
        if (isSearchRunning) {
            needSearchAgain = true
            return
        }
        
        isSearchRunning = true
        
        ItemOperationManager.default.startUpdateView(view: self)
        
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        localTrimmedID.removeAll()
        duplicatesArray.removeAll()
        serverDuplicatesArray.removeAll()
        
        dispatchQueue.async { [weak self] in
            
            self?.allLocalItems(completion: { [weak self] localItems in
                guard let `self` = self else {
                    return
                }
                
                self.localtemsArray.append(localItems.sorted { item1, item2 -> Bool in
                    if let date1 = item1.creationDate, let date2 = item2.creationDate {
                        if (date1 > date2) {
                            return true
                        }
                    }
                    return false
                })
                
                self.localMD5Array.append( self.localtemsArray.flatMap{ $0.md5 })
                self.localTrimmedID.append( self.localtemsArray.flatMap{ $0.getTrimmedLocalID() })
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
            })
        }
    }
    
    private func getDuplicatesObjects(latestDate: Date,
                                      success: @escaping ()-> Void,
                                      fail: @escaping ()-> Void) {
        guard let service = self.photoVideoService else {
            fail()
            return
        }
        var isFinished = false
        
        service.nextItemsMinified(sortBy: .date, sortOrder: .desc, success: { [weak self] items in
            self?.dispatchQueue.async { [weak self] in
                guard let `self` = self else {
                    fail()
                    return
                }
                
                for item in items {
                    if isFinished {
                        break
                    }
                    
                    autoreleasepool {
                        if let date = item.creationDate, date < latestDate {
                            isFinished = true
                        }
                        
                        if let index = self.localMD5Array.index(where:{ $0 == item.md5 }),
                            let elementToAdd = self.localtemsArray[index],
                            !isFinished
                        {
                            self.serverDuplicatesArray.append(item)
                            self.duplicatesArray.append(elementToAdd)
                            self.localtemsArray.remove(at: index)
                            self.localMD5Array.remove(at: index)
                            self.localTrimmedID.remove(at: index)
                            
                            if self.localtemsArray.isEmpty {
                                isFinished = true
                            }
                        } else if let index = self.localTrimmedID.index(where:{ $0 == item.getTrimmedLocalID() }),
                            let elementToAdd = self.localtemsArray[index],
                            !isFinished
                        {
                            self.serverDuplicatesArray.append(item)
                            self.duplicatesArray.append(elementToAdd)
                            self.localtemsArray.remove(at: index)
                            self.localMD5Array.remove(at: index)
                            self.localTrimmedID.remove(at: index)
                            
                            if self.localtemsArray.isEmpty {
                                isFinished = true
                            }
                        }
                    }
                }
                
                if isFinished || items.count < self.numberElementsInRequest {
                    success()
                } else {
                    self.getDuplicatesObjects(latestDate: latestDate, success: success, fail: fail)
                }
            }
        }, fail: {
            fail()
        }, newFieldValue: nil)
    }
    
    private func allLocalItems(completion: @escaping LocalFilesCallBack) {
        CoreDataStack.default.allLocalItems(completion: completion)
    }
    

    func getLocalFiesComaredWithServerObjectsAndClearFreeAppSpace(serverObjects: [WrapData], localObjects: [WrapData]) -> [WrapData] {
        var comparedFiles = [WrapData]()
        var objectsForRemove = [WrapData]()
        let serverObjectMD5Array = serverObjects.map { $0.md5 }
        let serverObjectsUUIDArray = serverObjects.map { $0.getTrimmedLocalID() }
        for localObject in localObjects {
            if serverObjectMD5Array.index(of: localObject.md5) != nil {
                comparedFiles.append(localObject)
            } else {
                if serverObjectsUUIDArray.index(of: localObject.getTrimmedLocalID()) != nil {
                    comparedFiles.append(localObject)
                } else {
                    objectsForRemove.append(localObject)
                }
            }
        }
        deleteDeletedLocalPhotos(deletedPhotos: objectsForRemove)
        return comparedFiles
    }
    
    // MARK: UploadNotificationManagerProtocol
    
    func finishedUploadFile(file: WrapData) {
        print("uploaded object with uuid - ", file.uuid)
        if (isSearchRunning) {
            needSearchAgain = true
            return
        }
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
        
            if file.isLocalItem {
                if self.localMD5Array.index(where: { $0 == file.md5 }) == nil {
                    file.metaData?.takenDate = Date()
                    self.localMD5Array.append(file.md5)
                    self.localTrimmedID.append(file.getTrimmedLocalID())
                }
                self.duplicatesArray.append(file)
            } else {
                print("uploaded server object")
                let serverObjectsUUIDs = self.serverDuplicatesArray.flatMap{ $0.uuid }
                if !serverObjectsUUIDs.contains(file.uuid) {
                    self.serverDuplicatesArray.append(file)
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
                    if self.localMD5Array.index(where: { $0 == localObject.md5 }) == nil {
                        file.metaData?.takenDate = Date()
                        self.localMD5Array.append(localObject.md5)
                        self.localTrimmedID.append(localObject.getTrimmedLocalID())
                    }
                    self.duplicatesArray.append(localObject)
                }
                
            }
            
            self.sortDuplicatesArray()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showFreeAppSpaceCard()
            }
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
                        file.metaData?.takenDate = Date()
                        self.duplicatesArray.append(localObject)
                        self.localMD5Array.append(localObject.md5)
                        self.localTrimmedID.append(localObject.getTrimmedLocalID())
                    }
                    self.sortDuplicatesArray()
                }
               self.checkFreeAppSpaceAfterAutoSync()
                
            })
            
        }
    }
    
    func addedLocalFiles(items: [Item]) {

        let serverObjectsUUIDs = serverDuplicatesArray.flatMap({ $0.uuid })

        for item in items {
            if serverObjectsUUIDs.contains(item.uuid) {
                localtemsArray.append(item)
                duplicatesArray.append(item)
            }
        }
    }
    
    func deleteItems(items: [Item]) {
//        SyncedBlock.synced(self) {
            dispatchQueue.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                if (self.isSearchRunning) {
                    self.needSearchAgain = true
                    return
                }
                
                let localObjects = items.filter {
                    $0.isLocalItem
                }
                
                var newDuplicatesArray = [WrapData]()
                let duplicatesMD5Set = Set<String>(localObjects.map({ $0.md5 }))
                
                self.duplicatesArray.forEach {
                    if !duplicatesMD5Set.contains($0.md5) {
                        newDuplicatesArray.append($0)
                    }
                }
                self.duplicatesArray.removeAll()
                self.duplicatesArray.append(newDuplicatesArray)
                
                var networksObjects = items.filter {
                    !$0.isLocalItem
                }
                
                var networksObjectsForDelete = [Item]()
                var duplicatesMD5Array = self.duplicatesArray.flatMap({ $0.md5 })
                for item in networksObjects {
                    if let index = duplicatesMD5Array.index(of: item.md5) {
                        duplicatesMD5Array.remove(at: index)
                        self.duplicatesArray.remove(at: index)
                    } else {
                        networksObjectsForDelete.append(item)
                    }
                }
                networksObjects = networksObjectsForDelete
                
                CoreDataStack.default.getLocalDuplicates(remoteItems: networksObjects, duplicatesCallBack: { [weak self] items in
                    guard let `self` = self else {
                        return
                    }
                    let duplicatesServerMD5Set = Set<String>(items.map({ $0.md5 }))
                    newDuplicatesArray.removeAll()
                    
                    self.duplicatesArray.forEach {
                        if !duplicatesServerMD5Set.contains($0.md5) {
                            newDuplicatesArray.append($0)
                        }
                    }
                    self.duplicatesArray.removeAll()
                    self.duplicatesArray.append(newDuplicatesArray)
                    
                    if (self.duplicatesArray.count == 0) {
                        CardsManager.default.stopOperationWithType(type: .freeAppSpace)
                        CardsManager.default.stopOperationWithType(type: .freeAppSpaceLocalWarning)
                    }
                })
                
            }
//        }
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
