//
//  ItemsProvider.swift
//  Depo
//
//  Created by Aleksandr on 10/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias ItemsCallback = (_ items: [WrapData])->Void

class ItemsProvider {///Maybe create also something like ItemsDownloader
    
    static let shared = ItemsProvider()
    
    private var allRemoteItems = [WrapData]()
    ///var previousRemoteItems
    
    var databasePageSize: Int = NumericConstants.numberOfLocalItemsOnPage
//    private var currentDataBasePage: Int = 0
    private var currentSearchAPIPage: Int = 0
    private var searchAPIPageSize: Int = NumericConstants.itemProviderSearchRequest
    private var isAllRemotesDownloaded = false
    
    private let searchPhotoVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest)
    //private let quickSearchService
    
    func updateCache() {
    ///check if there is a need to update or just download
        downloadNextRemoteItems(){ [weak self] in
            
        }
    }
    
    func updateItems() { ///QuickScroll API?
        
    }
    
    func reloadItems(callback: ItemsCallback) { ///Will be inactive after quickScroll API implementation

    }
    
    func getNextItems(newFieldValue: FieldValue?, callback: ItemsCallback) {
        
    }
    
    private func getItems(pageNum: Int, pageSize: Int, callback: ItemsCallback) {
        currentSearchAPIPage += 1
    }
    
    private func downloadNextRemoteItems(finished: @escaping VoidHandler) {
        searchPhotoVideoService.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
            guard let `self` = self else {
                return
            }
            
            self.allRemoteItems.append(contentsOf: remoteItems)
            
            if  remoteItems.count < self.searchAPIPageSize {
                self.isAllRemotesDownloaded = true
                finished()
                return
            }
            self.downloadNextRemoteItems(finished: finished)
            
            }, fail: { [weak self] in
                ///check reachability?
                //if ok - try once more? or just retry counter
                self?.searchPhotoVideoService.currentPage -= 1
                self?.downloadNextRemoteItems(finished: finished)
            }, newFieldValue: .imageAndVideo)
    }
    
    private func getSavedItems() {
        
    }
    
    private func saveItems() {
        
    }
    
    private func loadItems() {
        
    }
    
}
