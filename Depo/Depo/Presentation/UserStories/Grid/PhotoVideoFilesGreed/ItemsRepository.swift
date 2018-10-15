//
//  ItemsRepository.swift
//  Depo
//
//  Created by Aleksandr on 10/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class ItemsRepository {
    
    static let shared = ItemsRepository()
    
    private var isAllRemotesDownloaded = false
    private var allRemotePhotos = [WrapData]()
    private var allRemoteVideos = [WrapData]()
    func updateCache() {
        ///check if there is a need to update or just download
        downloadNextRemoteItems(){ [weak self] in
            
        }
    }
    
    func getAllPhotos() {
        
    }
    
    func getAllVideos() {
        
    }
    
    ///Download will be separated into download for photos pnly and videos only.
    ///just To help speed up page loading on the first launc
    private func downloadPhotos() {
        let searchPhotoVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .image)
        
    }
    
    private func downloadVideos() {
    
    }
        
    private func getSavedItems() {
        
    }
    
    private func saveItems() {
        
    }
    
    private func loadItems() {
        
    }
}

class ItemsDownloader {
    
    private var currentSearchAPIPage: Int = 0
    private var searchAPIPageSize: Int = NumericConstants.itemProviderSearchRequest
    
    private var allRemoteItems = [WrapData]()
    
    private let searchPhotoVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest)
    
    
    init(newFieldValue: FieldValue?) {
        
    }
    
    func downloadNextRemoteItems(finished: @escaping ItemsCallback) {
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
    
}
