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
        
    }// = ItemsRepository()
    
    fileprivate static var instance: ItemsRepository?
    
    let pathToMetaDataComponent = "MetaData"
    let pathToPhotoComponent = "StoragePhoto"
    let pathToVideoComponent = "StorageVideo"
    
    var isAllRemotesLoaded: Bool {
        return isAllPhotosLoaded && isAllVideosLoaded
    }
    private var isAllPhotosLoaded = false
    private var isAllVideosLoaded = false
    private var allRemotePhotos = [WrapData]()
    private var allRemoteVideos = [WrapData]()
    
    private var searchPhotoService: PhotoAndVideoService?
    private var searchVideoService: PhotoAndVideoService?
    
    var lastAddedPhotoPageCallback: VoidHandler?
    var lastAddedVideoPageCallback: VoidHandler?
    var allFilesDownloadedCallback: VoidHandler?
    
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.itemsRepositoryBackgroundQueue)
    ///array of delegates would be better then one callback (or array of callbacks??)
    
    func updateCache() {
        ///check if there is a need to update or just download
        loadItems() { [weak self] response in
            switch response {
            case .success(_):
////                self?.isAllPhotosLoaded = true
////                self?.isAllVideosLoaded = true
//                self?.lastAddedPhotoPageCallback?()
//                self?.lastAddedVideoPageCallback?()
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
                    self?.allFilesDownloadedCallback?()
                }
            }
        }
    }
    
    private func downloadAllFiles(completion: @escaping VoidHandler) {
        downloadPhotos() { [weak self] in
            //FIXME: implement as one method by providing different searchFilds value
            if let `self` = self, self.isAllRemotesLoaded {
                completion()
            }
        }
        downloadVideos() { [weak self] in
            if let `self` = self, self.isAllRemotesLoaded {
                completion()
            }
        }
    }
    
    func dropCache() {
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo else {
                return
        }
        searchPhotoService = nil
        searchVideoService = nil
        dropPhotoItems()
        dropVideoItems()
        allRemotePhotos.removeAll()
        allRemoteVideos.removeAll()
        PhotoVideoFilesGreedModuleStatusContainer.shared.isVideScreenPaginationDidEnd = false
        PhotoVideoFilesGreedModuleStatusContainer.shared.isPhotoScreenPaginationDidEnd = false
        isAllPhotosLoaded = false
        isAllVideosLoaded = false
        
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
        guard range.startIndex >= 0, range.startIndex < range.endIndex else {
            storedRemotes([])
            return
        }
        let arrayInRange = Array(allRemotePhotos.dropFirst(range.startIndex).prefix(range.endIndex - range.startIndex))
        if arrayInRange.isEmpty, !isAllPhotosLoaded {
            lastAddedPhotoPageCallback = { [weak self] in
                self?.getNextStoredPhotosPage(range: range, storedRemotes: storedRemotes)
            }
            return
        }
        storedRemotes(arrayInRange)
    }
    
    func getNextStoredVideosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        guard range.startIndex >= 0, range.startIndex < range.endIndex else {
            storedRemotes([])
            return
        }
        let arrayInRange = Array(allRemoteVideos.dropFirst(range.startIndex).prefix(range.endIndex - range.startIndex))
        if arrayInRange.isEmpty, !isAllVideosLoaded {
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
            guard let _ = self?.searchPhotoService else {
                return
            }
            self?.allRemotePhotos.append(contentsOf: remotes)
            self?.lastAddedPhotoPageCallback?()
            guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                self?.isAllPhotosLoaded = true
                finished()
                self?.searchPhotoService = nil
                return
            }
            self?.downloadPhotos(finished: finished)
        }, fail: { [weak self] in
            //Check Reachability?
            guard let _ = self?.searchPhotoService else {
                return
            }
            self?.searchPhotoService?.currentPage -= 1
            self?.downloadPhotos(finished: finished)
        })
        
    }
    
    private func downloadVideos(finished: @escaping VoidHandler) {
        if searchVideoService == nil {
            searchVideoService = PhotoAndVideoService(requestSize: NumericConstants.itemProviderSearchRequest, type: .video)
        }
        searchVideoService?.nextItems(sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remotes in
            guard let _ = self?.searchVideoService else {
                return
            }
            self?.allRemoteVideos.append(contentsOf: remotes)
            self?.lastAddedVideoPageCallback?()
            guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
                self?.isAllVideosLoaded = true
                finished()
                self?.searchVideoService = nil
                return
            }
            self?.downloadVideos(finished: finished)
            }, fail: { [weak self] in
                guard let _ = self?.searchVideoService else {
                    return
                }
                self?.searchVideoService?.currentPage -= 1
                self?.downloadVideos(finished: finished)
        })
    }
    
    private func saveItems() {
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo else {
                isAllPhotosLoaded = false
                isAllVideosLoaded = false
            return
        }
        
        archiveInRangeTillFinished(items: allRemotePhotos, toFile: pathPhoto)
        archiveInRangeTillFinished(items: allRemoteVideos, toFile: pathVideo)
//        NSKeyedArchiver.archiveRootObject(allRemotePhotos, toFile: pathPhoto)
//        NSKeyedArchiver.archiveRootObject(allRemoteVideos, toFile: pathVideo)
    }
    
    private func archiveInRangeTillFinished(items: [WrapData], toFile: String, pageNum: Int = 0) {
        let startIndex = pageNum * NumericConstants.itemProviderSearchRequest
        let endIndex = (pageNum + 1) * NumericConstants.itemProviderSearchRequest
        
         let arrayInRange = Array(items.dropFirst(startIndex).prefix(endIndex))
        guard !arrayInRange.isEmpty else {
            return
        }
        debugPrint("!-- archiveInRangeTillFinished \(pageNum)")
        let pathToSave = toFile + "\(pageNum)"
        NSKeyedArchiver.archiveRootObject(arrayInRange, toFile: pathToSave)
        archiveInRangeTillFinished(items: items, toFile: toFile, pageNum: pageNum + 1)
    }
    
    private func loadItems(callBack: @escaping ResponseVoid) {
        privateQueue.async { [weak self] in
            //TODO: If there is no videos - start downloading onl them,
            //if there is no photos - start downlading only photos
            
            self?.unArchivePhotoInRangeTillFinished(finished: { [weak self] result in
                guard let `self` = self else {
                    return
                }
                switch result {
                case .success(_):
                    if self.isAllRemotesLoaded {
                        callBack(result)
                    }
                case .failed(_):
                    callBack(result)
                }
            })

            self?.unArchiveVideoInRangeTillFinished(finished: { [weak self] result in
                guard let `self` = self else {
                    return
                }
                switch result {
                case .success(_):
                    if self.isAllRemotesLoaded {
                        callBack(result)
                    }
                case .failed(_):
                    callBack(result)
                }
            })
        }
    }
    
    private func unArchivePhotoInRangeTillFinished(pageNum: Int = 0, finished: @escaping ResponseVoid) {
        debugPrint("!-- unArchivePhotoInRangeTillFinished \(pageNum)")
        guard let pathPhoto = self.filePathPhoto,
            let savedPhotos = NSKeyedUnarchiver.unarchiveObject(withFile: pathPhoto + "\(pageNum)") as? [WrapData?]
            else {
                if allRemotePhotos.isEmpty {
                    finished(ResponseResult.failed(CustomErrors.unknown))
                } else {
                    self.isAllPhotosLoaded = true
                    self.lastAddedPhotoPageCallback?()
                    finished(.success(()))
                }
                return
        }
        allRemotePhotos.append(contentsOf: savedPhotos.flatMap{return $0})
        self.lastAddedPhotoPageCallback?()
        guard savedPhotos.count >= NumericConstants.itemProviderSearchRequest else {
            self.isAllPhotosLoaded = true
            finished(.success(()))
            return
        }
        unArchivePhotoInRangeTillFinished(pageNum: pageNum + 1, finished: finished)
    }
    
    private func unArchiveVideoInRangeTillFinished(pageNum: Int = 0, finished: @escaping ResponseVoid) {
        debugPrint("!-- unArchiveVideoInRangeTillFinished \(pageNum)")
        guard let pathVideo = self.filePathVideo,
            let savedVideos = NSKeyedUnarchiver.unarchiveObject(withFile: pathVideo + "\(pageNum)") as? [WrapData?]
            else {
                if allRemotePhotos.isEmpty {
                    finished(ResponseResult.failed(CustomErrors.unknown))
                } else {
                    self.isAllVideosLoaded = true
                    self.lastAddedVideoPageCallback?()
                    finished(.success(()))
                }
                return
        }
        allRemoteVideos.append(contentsOf: savedVideos.flatMap{return $0})
        self.lastAddedVideoPageCallback?()
        guard savedVideos.count >= NumericConstants.itemProviderSearchRequest else {
            self.isAllVideosLoaded = true
            finished(.success(()))
            return
        }
        unArchiveVideoInRangeTillFinished(pageNum: pageNum + 1, finished: finished)
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
        guard let unwrapedObj = object else {
            return
        }
        NSKeyedArchiver.archiveRootObject(unwrapedObj, toFile: path)
    }
    
    func unarchiveObject(path: String) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: path)
    }
    
}
