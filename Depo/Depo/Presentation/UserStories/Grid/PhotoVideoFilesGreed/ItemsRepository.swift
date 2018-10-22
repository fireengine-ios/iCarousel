//
//  ItemsRepository.swift
//  Depo
//
//  Created by Aleksandr on 10/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class ItemsRepository {//}: NSKeyedArchiverDelegate {
    
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
        loadItems() { [weak self] response in
            switch response {
            case .success(_):
                self?.isAllPhotosDownloaded = true
                self?.isAllVideosDownloaded = true
                self?.allFilesDownloadedCallback?()
                debugPrint("LALALA")
            case .failed(_):
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
            if let `self` = self, self.isAllRemotesDownloaded {
                completion()
            }
        }
        downloadVideos() { [weak self] in
            if let `self` = self, self.isAllRemotesDownloaded {
                completion()
            }
        }
    }
    
    func dropCache() {
        
    }
    
    func getNextStoredPhotosPage(range: CountableRange<Int>, storedRemotes: @escaping ItemsCallback) {
        guard range.startIndex >= 0, range.startIndex < range.endIndex else {
            storedRemotes([])
            return
        }
        let arrayInRange = Array(allRemotePhotos.dropFirst(range.startIndex).prefix(range.endIndex - range.startIndex))
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
            guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
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
            guard remotes.count >= NumericConstants.itemProviderSearchRequest else {
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
        ///OPTION 1:
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo else {
            return
        }

        NSKeyedArchiver.archiveRootObject(allRemotePhotos, toFile: pathPhoto)
        NSKeyedArchiver.archiveRootObject( allRemoteVideos, toFile: pathVideo)
        ///OPTION 2:
//        let data = NSKeyedArchiver.archivedDataWithRootObject(books)
//        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "books")
    }

    
    
    private func loadItems(callBack: @escaping ResponseVoid) {
        FileManager.default.fileExists(atPath: filePathPhoto!)
        //TODO: If there is no videos - start downloading onl them,
        //if there is no photos - start downlading only photos
        guard let pathPhoto = filePathPhoto,
            let pathVideo = filePathVideo,
            let savedPhotos = NSKeyedUnarchiver.unarchiveObject(withFile: pathPhoto) as? [WrapData?]
            ,
            let savedVideos = NSKeyedUnarchiver.unarchiveObject(withFile: pathVideo) as? [WrapData?]
            else {
                callBack(ResponseResult.failed(CustomErrors.unknown))
                return
        }
        
        allRemotePhotos = savedPhotos.flatMap{return $0}
        allRemoteVideos = savedVideos.flatMap{return $0}
        callBack(ResponseResult.success(()))
        
    }
    
//    var filePath : String {
//        let manager = NSFileManager.defaultManager()
//        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
//        return url.URLByAppendingPathComponent("objectsArray").path!
//    }
    let pathToMetaDataComponent = "MetaData"
    let pathToPhotoComponent = "StoragePhoto"
    //    let pathToPhotoMetaDataComponent = "StoragePhotoMetaData"
    let pathToVideoComponent = "StorageVideo"
    //    let pathToVideoMetaDataComponent = "StorageVideoMetaData"
    
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
    
    func deArchiveObject(path: String) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: path)
    }
    
}
