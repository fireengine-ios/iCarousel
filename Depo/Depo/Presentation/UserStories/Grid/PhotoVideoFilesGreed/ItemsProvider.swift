//
//  ItemsProvider.swift
//  Depo
//
//  Created by Aleksandr on 10/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias ItemsCallback = (_ items: [WrapData])->Void

class ItemsProvider {
    
    private let fieldValue: FieldValue
    private var allRemoteItems = [WrapData]()
    let itemsRepository = ItemsRepository.shared
    var databasePageSize = NumericConstants.numberOfLocalItemsOnPage
    private var currentDataBasePage: Int = 0

    var isAllFilesDownloaded: Bool {
        return itemsRepository.isAllRemotesDownloaded
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
    
    func reloadItems(callback: ItemsCallback) { ///Will be inactive after quickScroll API implementation

    }
    
    ///for photo And Videos while items being downloaded
    func getNextItems(callback: @escaping ItemsCallback) {
        currentDataBasePage += 1
        let nextPageRange = currentDataBasePage*databasePageSize..<(currentDataBasePage + 1)*databasePageSize
        switch fieldValue {
        case .image://FIXME just call one method with field value
            itemsRepository.getNextStoredPhotosPage(range: nextPageRange) { [weak self] remoteItems in
                self?.allRemoteItems.append(contentsOf: remoteItems)
                callback(remoteItems)
            }
        case .video:
            itemsRepository.getNextStoredVideosPage(range: nextPageRange) { [weak self] remoteItems in
                //                self?.currentDataBasePage += 1
                self?.allRemoteItems.append(contentsOf: remoteItems)
                callback(remoteItems)
            }
        default:
            break
        }
    }

    func getAllFieldRelatedSavedRemoteItems(itemsCallback: @escaping ItemsCallback) {
        //TODO: additional safety in ItemsRepository
        itemsRepository.getSavedAllSavedItems(fieldType: fieldValue, itemsCallback: itemsCallback)
    }
    
}
