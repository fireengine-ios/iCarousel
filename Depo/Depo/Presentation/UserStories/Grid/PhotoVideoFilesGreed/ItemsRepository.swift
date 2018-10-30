//
//  ItemsRepository.swift
//  Depo
//
//  Created by Aleksandr on 10/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class ItemsRepository {//}: NSKeyedArchiverDelegate {
    
    static let shared = ItemsRepository()
    
    let pathToMetaDataComponent = "MetaData"
    let pathToPhotoComponent = "StoragePhoto"
    let pathToVideoComponent = "StorageVideo"
    
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
    
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueue)
    private let privateConcurentQueue = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueue + "concurent", qos: .default , attributes: .concurrent)
    ///array of delegates would be better then one callback (or array of callbacks??)
    
    func updateCache() {
        ///check if there is a need to update or just download
        loadItems() { [weak self] response in
            switch response {
            case .success(_):
                self?.isAllPhotosDownloaded = true
                self?.isAllVideosDownloaded = true
                self?.lastAddedPhotoPageCallback?()
                self?.lastAddedVideoPageCallback?()
                self?.allFilesDownloadedCallback?()
            case .failed(_):
                self?.downloadAllFiles() { [weak self] in
                    self?.saveItems()
                    self?.allFilesDownloadedCallback?()
                }
            }
        }
    }
    
    private func downloadAllFiles(completion: @escaping VoidHandler) {
        privateQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.downloadPhotos() { [weak self] in
                //FIXME: implement as one method by providing different searchFilds value
                if let `self` = self, self.isAllRemotesDownloaded {
                    completion()
                }
            }
            self.downloadVideos() { [weak self] in
                if let `self` = self, self.isAllRemotesDownloaded {
                    completion()
                }
            }
        }
    }
    
    func dropCache() {
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo else {
                return
        }
        dropItem(path: pathPhoto)
        dropItem(path: pathVideo)
        allRemotePhotos.removeAll()
        allRemoteVideos.removeAll()
        PhotoVideoFilesGreedModuleStatusContainer.shared.isVideScreenPaginationDidEnd = false
        PhotoVideoFilesGreedModuleStatusContainer.shared.isPhotoScreenPaginationDidEnd = false
        isAllPhotosDownloaded = false
        isAllVideosDownloaded = false
    }
    
    private func dropItem(path: String) {
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    func getSavedAllSavedItems(fieldType: FieldValue, itemsCallback: @escaping ItemsCallback) {
        ///TODO: its better to add here the callback when all added then call the method again,
        ///BUT for that to happen we need array of callbacks or delegates
//        guard isAllRemotesDownloaded else {
//
//            return
//        }
        switch fieldType {
        case .image:
            itemsCallback(allRemotePhotos)
        case .video:
            itemsCallback(allRemoteVideos)
        default:
            break
        }
    }
    
    
    func getNextStoredPhotosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        privateConcurentQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard range.startIndex >= 0, range.startIndex < range.endIndex else {
                storedRemotes([])
                return
            }
            let arrayInRange = Array(self.allRemotePhotos.dropFirst(range.startIndex).prefix(range.endIndex - range.startIndex))
            if arrayInRange.isEmpty, !self.isAllPhotosDownloaded {
                self.lastAddedPhotoPageCallback = { [weak self] in
                    self?.getNextStoredPhotosPage(range: range, storedRemotes: storedRemotes)
                }
                return
            }
            storedRemotes(arrayInRange)
        }
    }
    
    func getNextStoredVideosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        privateConcurentQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard range.startIndex >= 0, range.startIndex < range.endIndex else {
                storedRemotes([])
                return
            }
            let arrayInRange = Array(self.allRemoteVideos.dropFirst(range.startIndex).prefix(range.endIndex - range.startIndex))
            if arrayInRange.isEmpty, !self.isAllVideosDownloaded {
                self.lastAddedVideoPageCallback = { [weak self] in
                    self?.getNextStoredVideosPage(range: range, storedRemotes: storedRemotes)
                }
                return
            }
            storedRemotes(arrayInRange)
        }
    }
    
    ///Download will be separated into download for photos pnly and videos only.
    ///just To help speed up page loading on the first launc
    private func downloadPhotos(finished: @escaping VoidHandler) {
        if searchPhotoService == nil {
            searchPhotoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .image)
        }
        searchPhotoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            self?.privateQueue.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.allRemotePhotos.append(contentsOf: remotes)
                self.lastAddedPhotoPageCallback?()
                guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                    self.isAllPhotosDownloaded = true
                    finished()
                    self.searchPhotoService = nil
                    return
                }
                self.downloadPhotos(finished: finished)
            }
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
            self?.privateQueue.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.allRemoteVideos.append(contentsOf: remotes)
                self.lastAddedVideoPageCallback?()
                guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                    self.isAllVideosDownloaded = true
                    finished()
                    self.searchVideoService = nil
                    return
                }
                
                self.downloadVideos(finished: finished)
            }
            }, fail: { [weak self] in
                self?.searchVideoService?.currentPage -= 1
                self?.downloadVideos(finished: finished)
        })
    }
    
    private func saveItems() {
        privateQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let pathPhoto = self.filePathPhoto,
                let pathVideo = self.filePathVideo else {
                    self.isAllPhotosDownloaded = false
                    self.isAllVideosDownloaded = false
                    return
            }
            NSKeyedArchiver.archiveRootObject(self.allRemotePhotos, toFile: pathPhoto)
            NSKeyedArchiver.archiveRootObject(self.allRemoteVideos, toFile: pathVideo)
        }
    }

    private func loadItems(callBack: @escaping ResponseVoid) {
        privateQueue.async { [weak self] in
            //TODO: If there is no videos - start downloading onl them,
            //if there is no photos - start downlading only photos
            guard let pathPhoto = self?.filePathPhoto,
                let pathVideo = self?.filePathVideo,
                let savedPhotos = NSKeyedUnarchiver.unarchiveObject(withFile: pathPhoto) as? [WrapData?],
                let savedVideos = NSKeyedUnarchiver.unarchiveObject(withFile: pathVideo) as? [WrapData?]
                else {
                    callBack(ResponseResult.failed(CustomErrors.unknown))
                    return
            }
            self?.allRemotePhotos = savedPhotos.flatMap{return $0}
            self?.allRemoteVideos = savedVideos.flatMap{return $0}
            callBack(ResponseResult.success(()))
        }
    }
    
    private var filePathURL: URL? {
        let manager = FileManager.default
        return manager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private var filePathPhoto: String? {
        return getPath(component: pathToPhotoComponent)
    }
    
    private var filePathVideo: String? {
        return getPath(component: pathToVideoComponent)
    }
    
    func getPath(component: String) -> String? {
         return filePathURL?.appendingPathComponent(component).path
    }
    
    func archiveObject(object: NSCoding?, path: String) {
        privateConcurentQueue.async {
            guard let unwrapedObj = object else {
                return
            }
            NSKeyedArchiver.archiveRootObject(unwrapedObj, toFile: path)
        }
    }
    
    func unarchiveObject(path: String) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: path)
    }
    
}
