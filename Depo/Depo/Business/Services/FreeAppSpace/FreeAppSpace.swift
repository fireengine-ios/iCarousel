//
//  FreeAppSpace.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpace: NSObject, ItemOperationManagerViewProtocol {
    
    static let `default` = FreeAppSpace()
    
    private var photoVideoService : PhotoAndVideoService? = nil
    private var isSearchRunning = false
    private var needSearchAgain = false
    private let numberElementsInRequest = 100
    
    private var localtemsArray = [WrapData]()
    private var localMD5Array = [String]()
    private var duplicaesArray = [WrapData]()
    private var serverDuplicatesArray = [WrapData]()
    
    func getDuplicatesObjects() -> [WrapData]{
        return duplicaesArray
    }
    
    func clear(){
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        duplicaesArray.removeAll()
        serverDuplicatesArray.removeAll()
        isSearchRunning = false
        if let service = photoVideoService{
            service.stopAllOperations()
            photoVideoService = nil
        }
    }
    
    func getServerUIDSForLocalitem(localItemsArray: [BaseDataSourceItem]) -> [String]{
        let serverHash = serverDuplicatesArray.map { $0.md5 }
        var array = [String]()
        for item in localItemsArray {
            let index  = serverHash.index(of: item.md5)
            if let index_ = index {
                let serverObject = serverDuplicatesArray[index_]
                array.append(serverObject.uuid)
            }
        }
        return array
    }
    
    func deleteDuplicates(serverItems: [BaseDataSourceItem]) {
        var array = [WrapData]()
        for serverObject in serverItems {
            if let index = localMD5Array.index(of: serverObject.md5){
                array.append(localtemsArray[index])
                
            }
        }
    }
    
    func checkFreeAppSpaceAfterAutoSync(){
        if (isSearchRunning){
            return
        }
        
        if duplicaesArray.count > 0 {
            showFreeAppSpaceCard()
        }else{
            checkFreeAppSpace()
        }
        
    }
    
    func checkFreeAppSpace(){
        startSearchDuplicates(finished: { [weak self] in
            guard let self_ = self else{
                return
            }
            
            self_.isSearchRunning = false
            
            if (self_.needSearchAgain){
                self_.needSearchAgain = true
                self_.checkFreeAppSpace()
                return
            }
            
            self_.showFreeAppSpaceCard()
        })
    }
    
    func showFreeAppSpaceCard(){
        if (duplicaesArray.count > 0){
            let freeSpace = Device.getFreeDiskSpaceInPercent
            if freeSpace < NumericConstants.freeAppSpaceLimit{
                CardsManager.default.startOperationWith(type: .freeAppSpaceWarning, allOperations: nil, completedOperations: nil)
            }else{
                CardsManager.default.startOperationWith(type: .freeAppSpace, allOperations: nil, completedOperations: nil)
            }
        }
    }
    
    func deleteDeletedLocalPhotos(deletedPhotos:[WrapData]){
        var array = duplicaesArray.map { $0.md5 }
        for object in deletedPhotos {
            if let index = array.index(of: object.md5){
                array.remove(at: index)
                duplicaesArray.remove(at: index)
            }
        }
    }
    
    func isDuplicatesNotAvailable() -> Bool{
        return duplicaesArray.count == 0
    }
    
    func startSearchDuplicates(finished: @escaping() -> Swift.Void) {
        if (isSearchRunning){
            needSearchAgain = true
            return
        }
        
        isSearchRunning = true
        
        ItemOperationManager.default.startUpdateView(view: self)
        
        localtemsArray.removeAll()
        localMD5Array.removeAll()
        duplicaesArray.removeAll()
        serverDuplicatesArray.removeAll()
        
        DispatchQueue.main.async {
            self.localtemsArray.append(contentsOf: self.allLocalItems().sorted { (item1, item2) -> Bool in
                if let date1 = item1.creationDate, let date2 = item2.creationDate {
                    if (date1 > date2){
                        return true
                    }
                }
                return false
            })
            
            self.localMD5Array.append(contentsOf: self.localtemsArray.map({$0.md5}))
            let latestDate = self.localtemsArray.last?.creationDate ?? Date()
            
            //need to check have we duplicates
            if self.localtemsArray.count > 0 {
                self.photoVideoService = PhotoAndVideoService(requestSize: self.numberElementsInRequest)
                self.getDuplicatesObjects(latestDate: latestDate, success: { [weak self] in
                    guard let self_ = self else{
                        return
                    }
                    if (self_.duplicaesArray.count > 0) {
                        debugPrint("duplicates count = ", self_.duplicaesArray.count)
                    }else{
                        debugPrint("have no duplicates")
                    }
                    finished()
                    }, fail: {
                        finished()
                })
            }else{
                finished()
            }
        }
        
    }
    
    private func getDuplicatesObjects(latestDate: Date,
                                      success: @escaping ()-> Swift.Void,
                                      fail: @escaping ()-> Swift.Void){

        guard let service = self.photoVideoService else{
            fail()
            return
        }
        var finished = false
        
        service.nextItems(sortBy: .date, sortOrder: .desc, success: { [weak self] (items) in
            guard let self_ = self else{
                fail()
                return
            }
            
            for item in items{
                if let date = item.creationDate, date < latestDate{
                    finished = true
                    break
                }
                let serverObjectMD5 = item.md5
                let index = self_.localMD5Array.index(of: serverObjectMD5)
                if let index_ = index {
                    
                    self_.serverDuplicatesArray.append(item)
                    self_.duplicaesArray.append(self_.localtemsArray[index_])
                    self_.localtemsArray.remove(at: index_)
                    self_.localMD5Array.remove(at: index_)
                    
                    if (self_.localtemsArray.count == 0){
                        finished = true
                        break
                    }
                }
            }
            
            if (!finished) && (items.count == self_.numberElementsInRequest){
                self_.getDuplicatesObjects(latestDate: latestDate, success: success, fail: fail)
            }else{
                success()
            }
        }, fail: {
            fail()
        }, newFieldValue: nil)
    }
    
    private func allLocalItems() -> [WrapData] {
        return CoreDataStack.default.allLocalItems()
    }
    
    func getLocalFiesComaredWithServerObjects(serverObjects: [WrapData], localObjects: [WrapData]) -> [WrapData]{
        var comparedFiles = [WrapData]()
        let localObjectMD5 = localObjects.map { $0.md5 }
        for serverObject in serverObjects{
            if let index = localObjectMD5.index(of: serverObject.md5) {
                comparedFiles.append(localObjects[index])
            }
        }
        return comparedFiles
    }
    
    //MARK: UploadNotificationManagerProtocol
    
    func startUploadFile(file: WrapData){
        
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float){
        
    }
    
    func finishedUploadFile(file: WrapData){
        if (isSearchRunning){
            needSearchAgain = true
            return
        }
        
        if file.isLocalItem{
            duplicaesArray.append(file)
        }else{
            serverDuplicatesArray.append(file)
            let fetchRequest = NSFetchRequest<MediaItem>(entityName: "MediaItem")
            let predicate = PredicateRules().allLocalObjectsForObjects(objects: [file])
            let sortDescriptors = CollectionSortingRules(sortingRules: .timeUp).rule.sortDescriptors
            
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            
            guard let fetchResult = try? CoreDataStack.default.mainContext.fetch(fetchRequest) else {
                return
            }
            let localObjects = fetchResult.map{ return WrapData(mediaItem: $0) }
            duplicaesArray.append(contentsOf: localObjects)
        }

        showFreeAppSpaceCard()
    }
    
    func addFilesToFavorites(items: [Item]){
        
    }
    
    func removeFileFromFavorites(items: [Item]){
        
    }
    
    func deleteItems(items: [Item]){
        if (isSearchRunning){
            needSearchAgain = true
            return
        }
        
        let md5Array = items.map { $0.md5 }
        var newDuplicatesArray = [WrapData]()
        for object in duplicaesArray {
            if !md5Array.contains(object.md5){
                newDuplicatesArray.append(object)
            }
        }
        duplicaesArray.removeAll()
        duplicaesArray.append(contentsOf: newDuplicatesArray)
        if (duplicaesArray.count == 0){
            CardsManager.default.stopOperationWithType(type: .freeAppSpace)
            CardsManager.default.stopOperationWithType(type: .freeAppSpaceWarning)
        }
    }
    
    func newFolderCreated(){
        
    }
    
    func newAlbumCreated(){
        
    }
    
    func albumsDeleted(albums: [AlbumItem]){
        
    }
    
    func fileAddedToAlbum(){
        
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool{
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
        }else{
            isGotAll = true
            let array = FreeAppSpace.default.getDuplicatesObjects()
            success?(array)
        }
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        allItems(success: success, fail: fail)
    }
    
    func clear(){
        isGotAll = false
    }
}
