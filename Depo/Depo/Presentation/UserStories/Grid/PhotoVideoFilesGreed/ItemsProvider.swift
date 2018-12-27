//
//  ItemsProvider.swift
//  Depo
//
//  Created by Aleksandr on 10/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias ItemsCallback = (_ items: [WrapData])->Void

class ItemsProvider {
    
    let fieldValue: FieldValue
    private var allRemoteItems = [WrapData]()
    let itemsRepository = ItemsRepository.sharedSession
    var databasePageSize = NumericConstants.numberOfLocalItemsOnPage
    private var currentDataBasePage: Int = 0

    var isAllFilesDownloaded: Bool {
        return itemsRepository.allItemsReady
    }
    
    //private let quickSearchService
    
    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    var currentPage: Int {
        return currentDataBasePage
    }
    
    func updateItems() { ///QuickScroll API?
        
    }
    
    func reloadItems(callback: @escaping ItemsCallback) { ///Will be inactive after quickScroll API implementation
        allRemoteItems.removeAll()
        currentDataBasePage = 0
        getNextItems(callback: callback)
    }
    
    func getCurrentRemotes() -> [WrapData] {
        return allRemoteItems
    }
    
    ///for photo And Videos while items being downloaded
    func getNextItems(callback: @escaping ItemsCallback) {
        
        currentDataBasePage += 1
        let nextPageRange = (currentDataBasePage - 1)*databasePageSize..<currentDataBasePage*databasePageSize
        
        switch fieldValue {
        case .image://FIXME just call one method with field value
            itemsRepository.getNextStoredPhotosPage(range: nextPageRange) { [weak self] remoteItems in
                self?.allRemoteItems.append(contentsOf: remoteItems)
                callback(remoteItems)
            }
        case .video:
            itemsRepository.getNextStoredVideosPage(range: nextPageRange) { [weak self] remoteItems in
                self?.allRemoteItems.append(contentsOf: remoteItems)
                callback(remoteItems)
            }
        default:
            break
        }
    }

//    func getAllFieldRelatedSavedRemoteItems(itemsCallback: @escaping ItemsCallback) {
//        //TODO: additional safety in ItemsRepository
//        itemsRepository.getSavedAllSavedItems(fieldType: fieldValue, itemsCallback: itemsCallback)
//    }
    
}
