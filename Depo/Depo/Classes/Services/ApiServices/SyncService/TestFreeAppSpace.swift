//
//  TestFreeAppSpace.swift
//  Depo_LifeTech
//
//  Created by Oleg on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

//class FreeAppSpace {
//    
//    static let `default` = FreeAppSpace()
//    
//    private var photoVideoService : PhotoAndVideoService? = nil
//    private var isSearchRunning = false
//    private let numberElementsInRequest = 100
//    
//    private var localtemsArray = [WrapData]()
//    private var localMD5Array = [String]()
//    private var duplicaesArray = [WrapData]()
//    private var serverDuplicatesArray = [WrapData]()
//    
//    func getDuplicatesObjects() -> [WrapData]{
//        return duplicaesArray
//    }
//    
//    func getServerUIDSForLocalitem(localItemsArray: [BaseDataSourceItem]) -> [String]{
//        let serverHash = serverDuplicatesArray.map { $0.md5 }
//        var array = [String]()
//        for item in localItemsArray {
//            let index  = serverHash.index(of: item.md5)
//            if let index_ = index {
//                let serverObject = serverDuplicatesArray[index_]
//                array.append(serverObject.uuid)
//            }
//        }
//        return array
//    }
//    
//    func deleteDuplicates(serverItems: [BaseDataSourceItem]) {
//        var array = [WrapData]()
//        for serverObject in serverItems {
//            if let index = localMD5Array.index(of: serverObject.md5){
//                array.append(localtemsArray[index])
//                
//            }
//        }
//    }
//    
//    func checkFreeAppSpace(){
//        let freeSpace = Device.getFreeDiskSpaceInPercent
//        if freeSpace < NumericConstants.freeAppSpaceLimit{
//            startSearchDuplicates(finished: { [weak self] in
//                guard let self_ = self else{
//                    return
//                }
//                if (self_.duplicaesArray.count > 0){
//                    WrapItemOperatonManager.default.startOperationWith(type: .freeAppSpaceWarning, allOperations: nil, completedOperations: nil)
//                }
//            })
//        }else{
//            startSearchDuplicates(finished: { [weak self] in
//                guard let self_ = self else{
//                    return
//                }
//                if (self_.duplicaesArray.count > 0){
//                    WrapItemOperatonManager.default.startOperationWith(type: .freeAppSpace, allOperations: nil, completedOperations: nil)
//                }
//            })
//        }
//    }
//    
//    
//    func startSearchDuplicates(finished: @escaping() -> Swift.Void) {
//        if (isSearchRunning){
//            return
//        }
//        
//        localtemsArray.removeAll()
//        localMD5Array.removeAll()
//        duplicaesArray.removeAll()
//        serverDuplicatesArray.removeAll()
//        
//        isSearchRunning = true
//        
//        localtemsArray.append(contentsOf: allLocalItems().sorted { (item1, item2) -> Bool in
//            if let date1 = item1.creationDate, let date2 = item2.creationDate {
//                if (date1 > date2){
//                    return true
//                }
//            }
//            return false
//        })
//        
//        localMD5Array.append(contentsOf: localtemsArray.map({$0.md5}))
//        let latestDate = localtemsArray.last?.creationDate ?? Date()
//        
//        //need to check have we duplicates
//        if localtemsArray.count > 0 {
//            photoVideoService = PhotoAndVideoService(requestSize: numberElementsInRequest)
//            getDuplicatesObjects(latestDate: latestDate, success: { [weak self] in
//                guard let self_ = self else{
//                    return
//                }
//                if (self_.duplicaesArray.count > 0) {
//                    debugPrint("duplicates count = ", self_.duplicaesArray.count)
//                }else{
//                    debugPrint("have no duplicates")
//                }
//                finished()
//                }, fail: {
//                    finished()
//            })
//        }else{
//            finished()
//        }
//    }
//    
//    private func getDuplicatesObjects(latestDate: Date,
//                                      success: @escaping ()-> Swift.Void,
//                                      fail: @escaping ()-> Swift.Void){
//        
//        guard let service = self.photoVideoService else{
//            fail()
//            return
//        }
//        var finished = false
//        
//        service.nextItems(sortBy: .date, sortOrder: .desc, success: { [weak self] (items) in
//            guard let self_ = self else{
//                fail()
//                return
//            }
//            
//            for item in items{
//                if let date = item.creationDate, date < latestDate{
//                    finished = true
//                    break
//                }
//                let serverObjectMD5 = item.md5
//                let index = self_.localMD5Array.index(of: serverObjectMD5)
//                if let index_ = index {
//                    
//                    self_.serverDuplicatesArray.append(item)
//                    self_.duplicaesArray.append(self_.localtemsArray[index_])
//                    self_.localtemsArray.remove(at: index_)
//                    self_.localMD5Array.remove(at: index_)
//                    
//                    if (self_.localtemsArray.count == 0){
//                        finished = true
//                        break
//                    }
//                }
//            }
//            
//            if (!finished) && (items.count == self_.numberElementsInRequest){
//                self_.getDuplicatesObjects(latestDate: latestDate, success: success, fail: fail)
//            }else{
//                success()
//            }
//            }, fail: {
//                fail()
//        }, newFieldValue: nil)
//    }
//    
//    private func allLocalItems() -> [WrapData] {
//        return CoreDataStack.default.allLocalItem()
//    }
//    
//}
//
//class FreeAppService: RemoteItemsService {
//    
//    /// server request don't have pagination
//    /// but we need this logic for the same logic
//    private var isGotAll = false
//    
//    init() {
//        super.init(requestSize: 9999, fieldValue: .audio)
//    }
//    
//    func allItems(success: ListRemoveItems?, fail: FailRemoteItems?) {
//        
//        if self.isGotAll {
//            success?([])
//            return
//        }else{
//            isGotAll = true
//            let array = FreeAppSpace.default.getDuplicatesObjects()
//            success?(array)
//        }
//    }
//    
//    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
//        allItems(success: success, fail: fail)
//    }
//}
//
