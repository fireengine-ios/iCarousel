//
//  ItemsRepository.swift
//  Depo
//
//  Created by Aleksandr on 10/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class ItemsRepository {
    
    static let shared = ItemsRepository()
    
    var isAllRemotesDownloaded: Bool {
        return isAllPhotosDownloaded && isAllVideosDownloaded
    }
    private var isAllPhotosDownloaded = false
    private var isAllVideosDownloaded = false
    private var allRemotePhotos = [WrapData]()
    private var allRemoteVideos = [WrapData]()
    
    private var searchPhotoService: PhotoAndVideoService?
    private var searchVideoService: PhotoAndVideoService?
    
    var lastAddedPhotoPageCallback: VoidHandler?
    var lastAddedVideoPageCallback: VoidHandler?
    var allFilesDownloadedCallback: VoidHandler?
    
    ///array of delegates
    
    func updateCache() {
        ///check if there is a need to update or just download
        
        /// if something stored flags isAllPhotosDownloaded are true

        downloadPhotos() { [weak self] in //FIXME: implement as one method by providing different searchFilds value
            if let `self` = self, self.isAllRemotesDownloaded {
                self.allFilesDownloadedCallback?()
            }
        }
        downloadVideos() { [weak self] in
            if let `self` = self, self.isAllRemotesDownloaded {
                self.allFilesDownloadedCallback?()
            }
        }
    }
    
    func getNextStoredPhotosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        ///in range numberOfLocalItemsOnPage
        let arrayInRange = Array(allRemotePhotos[range])
        if arrayInRange.isEmpty, !isAllPhotosDownloaded {
            lastAddedPhotoPageCallback = { [weak self] in
                self?.getNextStoredPhotosPage(range: range, storedRemotes: storedRemotes)
            }
            return
        }
        storedRemotes(arrayInRange)
    }
    
    func getNextStoredVideosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        let arrayInRange = Array(allRemoteVideos[range])
        if arrayInRange.isEmpty, !isAllVideosDownloaded {
            lastAddedVideoPageCallback = { [weak self] in
                self?.getNextStoredVideosPage(range: range, storedRemotes: storedRemotes)
            }
            return
        }
        storedRemotes(arrayInRange)
    }
    
    ///Download will be separated into download for photos pnly and videos only.
    ///just To help speed up page loading on the first launc
    private func downloadPhotos(finished: @escaping VoidHandler) {
        if searchPhotoService == nil {
            searchPhotoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .image)
        }
        searchPhotoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            self?.allRemotePhotos.append(contentsOf: remotes)
            self?.lastAddedPhotoPageCallback?()
            if remotes.count < NumericConstants.itemProviderSearchRequest {
                self?.isAllPhotosDownloaded = true
                finished()
                self?.searchPhotoService = nil
                return
            }
            self?.downloadPhotos(finished: finished)
        }, fail: { [weak self] in
            self?.searchPhotoService?.currentPage -= 1
            self?.downloadPhotos(finished: finished)
        })
        
    }
    
    private func downloadVideos(finished: @escaping VoidHandler) {
        if searchVideoService == nil {
            searchVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .video)
        }
        searchVideoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            self?.allRemoteVideos.append(contentsOf: remotes)
            self?.lastAddedVideoPageCallback?()
            if remotes.count < NumericConstants.itemProviderSearchRequest {
                self?.isAllVideosDownloaded = true
                finished()
                self?.searchVideoService = nil
                return
            }
            self?.downloadVideos(finished: finished)
            }, fail: { [weak self] in
                self?.searchVideoService?.currentPage -= 1
                self?.downloadVideos(finished: finished)
        })
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
//        searchPhotoVideoService.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
//            guard let `self` = self else {
//                return
//            }
//            
//            self.allRemoteItems.append(contentsOf: remoteItems)
//            
//            if  remoteItems.count < self.searchAPIPageSize {
//                self.isAllRemotesDownloaded = true
//                finished()
//                return
//            }
//            self.downloadNextRemoteItems(finished: finished)
//            
//            }, fail: { [weak self] in
//                ///check reachability?
//                //if ok - try once more? or just retry counter
//                self?.searchPhotoVideoService.currentPage -= 1
//                self?.downloadNextRemoteItems(finished: finished)
//            }, newFieldValue: .imageAndVideo)
    }
    
}
