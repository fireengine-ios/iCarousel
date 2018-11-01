//
//  ItemsRepository.swift
//  Depo
//
//  Created by Aleksandr on 10/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class ItemsRepository {
    
    static var shared: ItemsRepository {
        if let unwrapedInstance = ItemsRepository.instance {
            return unwrapedInstance
        } else {
            let newInstance = ItemsRepository()
            instance = newInstance
            return newInstance
        }
    }
    
    fileprivate static var instance: ItemsRepository?
    
    let pathToMetaDataComponent = "MetaData"
    private let pathToPhotoComponent = "StoragePhoto"
    private let pathToVideoComponent = "StorageVideo"
    
    private var isAllRemotesLoaded: Bool {
        debugPrint("!-- isAllRemotesLoaded \(isAllPhotosLoaded && isAllVideosLoaded), isAllPhotosLoaded \(isAllPhotosLoaded), isAllVideosLoaded \(isAllVideosLoaded)")
        return isAllPhotosLoaded && isAllVideosLoaded
    }
    private var isAllPhotosLoaded = false
    private var isAllVideosLoaded = false
    
    var allItemsReady = false
    
    //FIXME: flags too similar
//    private var isPhotoLoadDone = false
//    private var isVideoLoadDone = false
    
    private var allRemotePhotos = [WrapData]()
    private var allRemoteVideos = [WrapData]()
    
    private var searchPhotoService: PhotoAndVideoService?
    private var searchVideoService: PhotoAndVideoService?
    
    ///array of delegates would be better then one callback
    var lastAddedPhotoPageCallback: VoidHandler?
    var lastAddedVideoPageCallback: VoidHandler?
    var allFilesDownloadedCallback: VoidHandler?
    
    private let privateQueuePhoto = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueuePhoto)
    private let privateQueueVideo = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueueVideo)
    private let privateConcurentQueue = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueueConcurent, qos: .default , attributes: .concurrent)
    
    func updateCache() {
        ///check if there is a need to update or just download
        loadItems() { [weak self] response in
            switch response {
            case .success(_):
                self?.isAllPhotosLoaded = true
                self?.isAllVideosLoaded = true
                self?.lastAddedPhotoPageCallback?()
                self?.lastAddedVideoPageCallback?()
                self?.allItemsReady = true
                self?.allFilesDownloadedCallback?()
            case .failed(_):
                ///unnessery if something was stored ?
                self?.isAllPhotosLoaded = false
                self?.isAllVideosLoaded = false
                self?.allRemotePhotos.removeAll()
                self?.allRemoteVideos.removeAll()
                ///
                self?.downloadAllFiles() { [weak self] in
                    self?.saveItems()
                    self?.allItemsReady = true
                    self?.allFilesDownloadedCallback?()
                }
            }
        }
    }
    
    private func downloadAllFiles(completion: @escaping VoidHandler) {
        privateQueuePhoto.async { [weak self] in
            self?.downloadPhotos() { [weak self] in
                //FIXME: implement as one method by providing different searchFilds value
                if let `self` = self, self.isAllRemotesLoaded {
                    completion()
                }
            }
        }
        privateQueueVideo.async {
            self.downloadVideos() { [weak self] in
                if let `self` = self, self.isAllRemotesLoaded {
                    completion()
                }
            }
        }
    }
    
    ///Download will be separated into download for photos pnly and videos only.
    ///just To help speed up page loading on the first launc
    private func downloadPhotos(finished: @escaping VoidHandler) {
        if searchPhotoService == nil {
            searchPhotoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .image)
        }
        searchPhotoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            self?.privateQueuePhoto.async { [weak self] in
                debugPrint("!--downloadPhotos number of remotes \(remotes.count)")
                guard let `self` = self,
                    let _ = self.searchPhotoService else {
                    return
                }
                self.allRemotePhotos.append(contentsOf: remotes)
                self.lastAddedPhotoPageCallback?()
                guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                    self.isAllPhotosLoaded = true
                    self.searchPhotoService = nil
                    finished()
                    return
                }
                self.downloadPhotos(finished: finished)
            }
        }, fail: { [weak self] in
            self?.privateQueuePhoto.async { [weak self] in
                guard let _ = self?.searchPhotoService else {
                    return
                }
                self?.searchPhotoService?.currentPage -= 1
                self?.downloadPhotos(finished: finished)
            }
        })
        
    }
    
    private func downloadVideos(finished: @escaping VoidHandler) {
        if searchVideoService == nil {
            searchVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .video)
        }
        searchVideoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            self?.privateQueueVideo.async { [weak self] in
                debugPrint("!--downloadVideos number of remotes \(remotes.count)")
                guard let `self` = self,
                    let _ = self.searchVideoService else {
                        return
                }
                self.allRemoteVideos.append(contentsOf: remotes)
                self.lastAddedVideoPageCallback?()
                guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                    self.isAllVideosLoaded = true
                    self.searchVideoService = nil
                    finished()
                    return
                }
                
                self.downloadVideos(finished: finished)
            }
            }, fail: { [weak self] in
                self?.privateQueueVideo.async { [weak self] in
                    guard let _ = self?.searchVideoService else {
                        return
                    }
                    self?.searchVideoService?.currentPage -= 1
                    self?.downloadVideos(finished: finished)
                }
        })
    }
    
    private func saveItems() {
        guard let pathPhoto = self.filePathPhoto,
            let pathVideo = self.filePathVideo else {
                self.isAllPhotosLoaded = false
                self.isAllVideosLoaded = false
                return
        }
        debugPrint("!-- saveItems ALL PHOTOS array count \(self.allRemotePhotos.count)")
        privateQueuePhoto.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.archiveInRangeTillFinished(items: self.allRemotePhotos, toFile: pathPhoto)
        }
        
        debugPrint("!-- saveItems ALL VIDEOS array count \(self.allRemoteVideos.count)")
        privateQueueVideo.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.archiveInRangeTillFinished(items: self.allRemoteVideos, toFile: pathVideo)
        }
        
    }
    
    private func loadItems(callBack: @escaping ResponseVoid) {
        isAllPhotosLoaded = false
        isAllVideosLoaded = false
        
        unArchivePhotoInRangeTillFinished(finished: { [weak self] result in
            guard let `self` = self else {
                return
            }
            if self.isAllRemotesLoaded {
                callBack(result)
            }
        })


        unArchiveVideoInRangeTillFinished(finished: { [weak self] result in
            guard let `self` = self else {
                return
            }
            if self.isAllRemotesLoaded {
                callBack(result)
            }
        })
    }
    
    
    //MARK:- Drop
    
    func dropCache() {
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo else {
                return
        }
        searchPhotoService = nil
        searchVideoService = nil
//        isPhotoLoadDone = false
//        isVideoLoadDone = false
        dropPhotoItems()
        dropVideoItems()
        allRemotePhotos.removeAll()
        allRemoteVideos.removeAll()
        PhotoVideoFilesGreedModuleStatusContainer.shared.isVideScreenPaginationDidEnd = false
        PhotoVideoFilesGreedModuleStatusContainer.shared.isPhotoScreenPaginationDidEnd = false
        isAllPhotosLoaded = false
        isAllVideosLoaded = false
        allItemsReady = false
        
        ///FOR now its easier and more efficient to create new instance then canceling ongoing request/or operation
        ItemsRepository.instance = nil
    }
    
    private func dropPhotoItems(pageNum: Int = 0) {
        guard let pathPhoto = self.filePathPhoto else {
            return
        }
        debugPrint("!-- dropPhotoItems \(pageNum)")
        dropItem(path: pathPhoto + "\(pageNum)") { [weak self] in
            self?.dropPhotoItems(pageNum: pageNum + 1)
        }
    }
    
    private func dropVideoItems(pageNum: Int = 0) {
        guard let pathVideo = self.filePathVideo  else {
            return
        }
        debugPrint("!-- dropVideoItems \(pageNum)")
        dropItem(path: pathVideo + "\(pageNum)") { [weak self] in
            self?.dropVideoItems(pageNum: pageNum + 1)
        }
    }
    
    private func dropItem(path: String, callback: VoidHandler) {
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}

//MARK:- Archiving/Unarchiving stuff
extension ItemsRepository {
    
    private func archiveInRangeTillFinished(items: [WrapData], toFile: String, pageNum: Int = 0) {
        
        let startIndex = pageNum * NumericConstants.itemProviderSearchRequest
        let endIndex = (pageNum + 1) * NumericConstants.itemProviderSearchRequest
        
        let arrayInRange = Array(items.dropFirst(startIndex).prefix(endIndex))
        debugPrint("!-- archiveInRangeTillFinished array count\(arrayInRange.count)")
        guard !arrayInRange.isEmpty else {
            return
        }
        let pathToSave = toFile + "\(pageNum)"
        debugPrint("!-- archiveInRangeTillFinished \(pageNum) with path \(pathToSave)")
        
        NSKeyedArchiver.archiveRootObject(arrayInRange, toFile: pathToSave)
        archiveInRangeTillFinished(items: items, toFile: toFile, pageNum: pageNum + 1)
        
    }
    
    private func unArchivePhotoInRangeTillFinished(pageNum: Int = 0, finished: @escaping ResponseVoid) {
        debugPrint("!-- unArchivePhotoInRangeTillFinished \(pageNum)")
        self.privateQueuePhoto.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let pathPhoto = self.filePathPhoto,
                let savedPhotos = NSKeyedUnarchiver.unarchiveObject(withFile: pathPhoto + "\(pageNum)") as? [WrapData?]
                else {
                    self.isAllPhotosLoaded = true
                    if self.allRemotePhotos.isEmpty {
                        finished(ResponseResult.failed(CustomErrors.unknown))
                    } else {
                        self.lastAddedPhotoPageCallback?()
                        finished(.success(()))
                    }
                    return
            }
            self.allRemotePhotos.append(contentsOf: savedPhotos.flatMap{return $0})
            self.lastAddedPhotoPageCallback?()
            guard savedPhotos.count >= NumericConstants.itemProviderSearchRequest else {
                self.isAllPhotosLoaded = true
                finished(.success(()))
                return
            }
            self.unArchivePhotoInRangeTillFinished(pageNum: pageNum + 1, finished: finished)
        }
    }
    
    private func unArchiveVideoInRangeTillFinished(pageNum: Int = 0, finished: @escaping ResponseVoid) {
        debugPrint("!-- unArchiveVideoInRangeTillFinished \(pageNum)")
        self.privateQueueVideo.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let pathVideo = self.filePathVideo,
                let savedVideos = NSKeyedUnarchiver.unarchiveObject(withFile: pathVideo + "\(pageNum)") as? [WrapData?]
                else {
                    self.isAllVideosLoaded = true
                    if self.allRemoteVideos.isEmpty {
                        finished(ResponseResult.failed(CustomErrors.unknown))
                    } else {
                        self.lastAddedVideoPageCallback?()
                        finished(.success(()))
                    }
                    return
            }
            self.allRemoteVideos.append(contentsOf: savedVideos.flatMap{return $0})
            self.lastAddedVideoPageCallback?()
            guard savedVideos.count >= NumericConstants.itemProviderSearchRequest else {
                self.isAllVideosLoaded = true
                finished(.success(()))
                return
            }
            self.unArchiveVideoInRangeTillFinished(pageNum: pageNum + 1, finished: finished)
        }
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

//MARK:- File Path Stuff
extension ItemsRepository {
    
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
    
}

//MARK:- Items BY page provider
extension ItemsRepository {
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
            if arrayInRange.isEmpty, !self.isAllPhotosLoaded {
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
            if arrayInRange.isEmpty, !self.isAllVideosLoaded {
                self.lastAddedVideoPageCallback = { [weak self] in
                    self?.getNextStoredVideosPage(range: range, storedRemotes: storedRemotes)
                }
                return
            }
            storedRemotes(arrayInRange)
        }
    }
}
