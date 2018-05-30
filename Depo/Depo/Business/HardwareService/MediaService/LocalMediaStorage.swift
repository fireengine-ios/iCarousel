//
//  FilesLocalDataSource.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import Photos

typealias PhotoLibraryGranted = (_ granted: Bool, _ status: PHAuthorizationStatus) -> Void

typealias FileDataSorceImg = (_ image: UIImage?) -> Void

typealias AssetsList = (_ assets: [PHAsset] ) -> Void

struct AssetInfo {
    var asset: PHAsset
    var isValid = true
    var url = LocalMediaStorage.defaultUrl
    var size = Int64(0)
    var name = ""
    var md5: String {
        if !name.isEmpty && size > 0 {
            return "\(name.removeAllPreFileExtentionBracketValues())\(size)"
        }
        return LocalMediaStorage.noneMD5
    }
    
    init(libraryAsset: PHAsset) {
        asset = libraryAsset
        url = LocalMediaStorage.defaultUrl
        size = Int64(0)
        name = ""
    }
    
    init(fileAsset: PHAsset, fileUrl: URL, fileSize: Int64, fileName: String) {
        asset = fileAsset
        url = fileUrl
        size = fileSize
        name = fileName
    }
    
}



protocol LocalMediaStorageProtocol {
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func getAllImagesAndVideoAssets() -> [PHAsset]
    
    func removeAssets(deleteAsset: [PHAsset], success: FileOperation?, fail: FailResponse?)
    
    func copyAssetToDocument(asset: PHAsset) -> URL?
    
    func fullInfoAboutAsset(asset: PHAsset) -> AssetInfo
    
    func clearTemporaryFolder()
}

class LocalMediaStorage: NSObject, LocalMediaStorageProtocol {
    
    static let `default` = LocalMediaStorage()
        
    private let photoManger = PHImageManager.default()
    
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private lazy var coreDataStack = CoreDataStack.default
    
    private lazy var streamReaderWrite = StreamReaderWriter()
    
    private let queue = OperationQueue()
    
    private let getDetailQueue = OperationQueue()
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.localMediaStorage, attributes: .concurrent)
    
    static let defaultUrl = URL(string: "http://Not.url.com")!
    
    static let noneMD5 = "NONE MD5"
    
    var assetsCache = AssetsCache()
    
    private override init() {
        queue.maxConcurrentOperationCount = 1
        
        super.init()
        self.photoLibrary.register(self)
    }
    
    func photoLibraryIsAvailible() -> Bool {

        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
    }
    
    func getInfo(from assets: [PHAsset], completion: @escaping (_ assetsInfo: [AssetInfo])->Void) {
        var assetsInfo = [AssetInfo]()
        
        for asset in assets {
            autoreleasepool {
                let assetInfo = self.fullInfoAboutAsset(asset: asset)
                assetsInfo.append(assetInfo)
            }
        }
        completion(assetsInfo)
    }
    
    func getCompactInfo(from assets: [PHAsset], completion: @escaping (_ assetsInfo: [AssetInfo])->Void) {
        var assetsInfo = [AssetInfo]()
        
        for asset in assets {
            autoreleasepool {
                let assetInfo = self.compactInfoAboutAsset(asset: asset)
                assetsInfo.append(assetInfo)
            }
        }
        completion(assetsInfo)
    }
    
    func clearTemporaryFolder() {
        log.debug("LocalMediaStorage clearTemporaryFolder")
        
        do {
            let folderPath = Device.tmpFolderString()
            try FileManager.default.contentsOfDirectory(atPath: folderPath).forEach { path in
                try FileManager.default.removeItem(atPath: folderPath.stringByAppendingPathComponent(path: path))
            }
        } catch {
            print(error.description)
        }
    }
    
    // MARK: Alerts
    private func showAccessAlert() {
        log.debug("LocalMediaStorage showAccessAlert")

        let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                              message: TextConstants.cameraAccessAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                              secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                              secondAction: { vc in
                                                vc.close {
                                                    UIApplication.shared.openSettings()
                                                }
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func askPermissionForPhotoFramework(redirectToSettings: Bool, completion: @escaping PhotoLibraryGranted) {

        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if (Device.operationSystemVersionLessThen(10)) {
                PHPhotoLibrary.requestAuthorization({ authStatus in
                    let isAuthorized = authStatus == .authorized
                    completion(isAuthorized, authStatus)
                })
            } else {
                completion(true, status)
            }
            MenloworksTagsService.shared.onGalleryPermissionChanged(true)
        case .notDetermined, .restricted:
            passcodeStorage.systemCallOnScreen = true
            PHPhotoLibrary.requestAuthorization({ [weak self] authStatus in
                self?.passcodeStorage.systemCallOnScreen = false
                let isAuthorized = authStatus == .authorized
                MenloworksTagsService.shared.onGalleryPermissionChanged(isAuthorized)
                completion(isAuthorized, authStatus)
            })
        case .denied:
            completion(false, status)
            if redirectToSettings {
                DispatchQueue.main.async {
                    MenloworksTagsService.shared.onGalleryPermissionChanged(false)
                    self.showAccessAlert()
                }
            }
        }
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    func getAllImagesAndVideoAssets() -> [PHAsset] {
        assetsCache.dropAll()
        log.debug("LocalMediaStorage getAllImagesAndVideoAssets")

        guard photoLibraryIsAvailible() else {
            return []
        }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: options)
        
        var mediaContent = [PHAsset]()
        
        fetchResult.enumerateObjects({ avalibleAset, index, a in
            mediaContent.append(avalibleAset)
        })
        
        assetsCache.append(list: mediaContent)
        return mediaContent
    }
    
    func getAllAlbums(completion: @escaping (_ albums: [AlbumItem]) -> Void) {
        log.debug("LocalMediaStorage getAllAlbums")

        askPermissionForPhotoFramework(redirectToSettings: true) { accessGranted, _ in
            guard accessGranted else {
                completion([])
                return
            }
            
            DispatchQueue.global().async {
                let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                
                var albums = [AlbumItem]()
                
                [album, smartAlbum].forEach { album in
                    album.enumerateObjects { object, index, stop in
                        let count = self.numberOfItems(in: object)
                        if count.value > 0 {
                            let item = AlbumItem(uuid: object.localIdentifier,
                                                 name: object.localizedTitle,
                                                 creationDate: nil,
                                                 lastModifiDate: nil,
                                                 fileType: .photoAlbum,
                                                 syncStatus: .unknown,
                                                 isLocalItem: true)
                            if count.fromCoreData {
                                item.imageCount = count.value
                            }
                            
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                            
                            if let asset = PHAsset.fetchAssets(in: object, options: fetchOptions).firstObject {
                                
                                item.preview = WrapData(asset: asset)
                            }
                            albums.append(item)
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(albums)
                }
            }
        }
    }
    
    private func numberOfItems(in album: PHAssetCollection) -> (value: Int, fromCoreData: Bool) {
        guard !coreDataStack.inProcessAppendingLocalFiles else {
            return (album.photosCount + album.videosCount, false)
        }
        
        let assets = PHAsset.fetchAssets(in: album, options: PHFetchOptions())
        let array = assets.objects(at: IndexSet(0..<assets.count))
        let context = coreDataStack.newChildBackgroundContext
        let ids = coreDataStack.listAssetIdAlreadySaved(allList: array, context: context)
        
        return (ids.count, true)
    }
    
    // MARK: Image
    
    func getPreviewMaxImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        log.debug("LocalMediaStorage getPreviewMaxImage")

        getImage(asset: asset,
                 contentSize: PHImageManagerMaximumSize,
                 image: image)
    }
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        log.debug("LocalMediaStorage getPreviewImage")

        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 300, height: 300),
                 image: image)
    }
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg) {
        log.debug("LocalMediaStorage getBigImageFromFile")

        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 768.0, height: 768.0),
                 image: image)
    }
    
    func getImage(asset: PHAsset, contentSize: CGSize, convertToSize: CGSize, image: @escaping FileDataSorceImg) {
        log.debug("LocalMediaStorage getImage")
        
        let scalling: PhotoManagerCallBack = { [weak self] input, dict in
            self?.dispatchQueue.async {
                let newImg = input?.resizeImage(rect: contentSize)
                    image(newImg)
                
            }
        }
        
        let operation = GetImageOperation(photoManager: photoManger,
                                          asset: asset,
                                          targetSize: convertToSize,
                                          callback: scalling)
        queue.addOperation(operation)
    }
    
    func getImage(asset: PHAsset, contentSize: CGSize, image: @escaping FileDataSorceImg) {
        log.debug("LocalMediaStorage getImage")

        let callBack: PhotoManagerCallBack = { newImg, _ in
            DispatchQueue.main.async {
                image(newImg)
            }
        }
        let operation = GetImageOperation(photoManager: photoManger,
                                          asset: asset,
                                          targetSize: contentSize,
                                          callback: callBack)
        queue.addOperation(operation)
    }
    
    
    // MARK: insert remove Asset
    
    func removeAssets(deleteAsset: [PHAsset], success: FileOperation?, fail: FailResponse?) {
        log.debug("LocalMediaStorage removeAssets")

        guard photoLibraryIsAvailible() else {
            fail?(.failResponse(nil))
            return
        }
        
        passcodeStorage.systemCallOnScreen = true
        
        PHPhotoLibrary.shared().performChanges({
            
            let listToDelete = NSArray(array: deleteAsset)
            
            PHAssetChangeRequest.deleteAssets(listToDelete)
            
        }, completionHandler: { [weak self] status, error in
            log.debug("LocalMediaStorage removeAssets PHPhotoLibrary performChanges success")
            
            self?.passcodeStorage.systemCallOnScreen = false
            
            if (status) {
                success?()
            } else {
                log.debug("LocalMediaStorage removeAssets PHPhotoLibrary fail")

                fail?(.error(error!))
            }
        })
    }
    
    /*
     * if album = nil put to camera rool
     * 
     */
    func appendToAlboum(fileUrl: URL, type: PHAssetMediaType, album: String?, item: WrapData? = nil, success: FileOperation?, fail: FailResponse?) {
        log.debug("LocalMediaStorage appendToAlboum")

        guard photoLibraryIsAvailible() else {
            fail?(.failResponse(nil))
            return
        }
        
        passcodeStorage.systemCallOnScreen = true
        
        var assetPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            switch type {
                case .image:
                    assetPlaceholder = self.createRequestAppendImageToAlbum(fileUrl: fileUrl)
                case .video:
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                    assetPlaceholder = request?.placeholderForCreatedAsset
                default:
                fail?(.string("Only for photo & Video"))
            }
            
        }, completionHandler: { [weak self] status, error in
            self?.passcodeStorage.systemCallOnScreen = false
            
            if status {
                if let album = album, let assetPlaceholder = assetPlaceholder {
                    self?.add(asset: assetPlaceholder.localIdentifier, to: album)
                }
                if let item = item, let assetIdentifier = assetPlaceholder?.localIdentifier {
                    self?.merge(asset: assetIdentifier, with: item)
                }
                success?()
            } else {
                fail?(.error(error!))
            }
        })

    }
    
    var addAssetToCollectionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func saveFilteredImage(filteredImage: UIImage, originalImage: Item) {
        var localTempoID = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
            guard let localID = request.placeholderForCreatedAsset?.localIdentifier else {
                return
            }
            localTempoID = localID
        }, completionHandler: { [weak self] status, error in
            self?.merge(asset: localTempoID, with: originalImage, isFilteredItem: true)
        })
        
    }
    
    private func merge(asset assetIdentifier: String, with item: WrapData, isFilteredItem: Bool = false) {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject {
            LocalMediaStorage.default.assetsCache.append(list: [asset])
            let wrapData = WrapData(asset: asset)
            wrapData.copyFileData(from: item)
            
            let context = CoreDataStack.default.newChildBackgroundContext
            context.perform { [weak self] in
                let mediaItem: MediaItem
                if let existingMediaItem = CoreDataStack.default.mediaItemByLocalID(trimmedLocalIDS: [item.getTrimmedLocalID()]).first {
                    mediaItem = existingMediaItem
                } else {
                    mediaItem = MediaItem(wrapData: wrapData, context: context)
                }

                mediaItem.localFileID = assetIdentifier
                mediaItem.trimmedLocalFileID = assetIdentifier.components(separatedBy: "/").first ?? assetIdentifier//item.getTrimmedLocalID()
                mediaItem.syncStatusValue = SyncWrapperedStatus.synced.valueForCoreDataMapping()
                
                if isFilteredItem {
                   mediaItem.isFiltered = true
                }
                
                var userObjectSyncStatus = Set<MediaItemsObjectSyncStatus>()
                if let unwrapedSet = mediaItem.objectSyncStatus as? Set<MediaItemsObjectSyncStatus> {
                    userObjectSyncStatus = unwrapedSet
                }
                SingletonStorage.shared.getUniqueUserID(success: {
                    currentUserID in
                    context.perform {
                        mediaItem.objectSyncStatus = NSSet(set: userObjectSyncStatus)
                        userObjectSyncStatus.insert(MediaItemsObjectSyncStatus(userID: currentUserID, context: context))
                        CoreDataStack.default.saveDataForContext(context: context, savedCallBack: nil)
                        }
                    }, fail: {
                        /// nothing, status not going to be saved
                })
            }
            
        }
    }
    
    fileprivate func add(asset assetIdentifier: String, to album: String) {
        askPermissionForPhotoFramework(redirectToSettings: true, completion: { accessGranted, _ in
            if accessGranted {
                let operation = AddAssetToCollectionOperation(albumName: album, assetIdentifier: assetIdentifier)
                self.addAssetToCollectionQueue.addOperation(operation)
            }
        })
    }
    
    fileprivate func createRequestAppendImageToAlbum(fileUrl: URL) -> PHObjectPlaceholder? {
        do {
            if let image = try UIImage(data: Data(contentsOf: fileUrl)) {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                return request.placeholderForCreatedAsset
            }
            
        } catch {
            print(error.description)
        }
        return nil
    }
    
    fileprivate func add(asset assetIdentifier: String, to collection: PHAssetCollection) {
        passcodeStorage.systemCallOnScreen = true
        let assetRequest = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            self?.passcodeStorage.systemCallOnScreen = false
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.addAssets(assetRequest)
        }, completionHandler: nil)
    }
    
    typealias AssetCollectionCompletion = (_ collection: PHAssetCollection?) -> Void
    
    func createAlbum(_ name: String, completion: @escaping AssetCollectionCompletion) {
        log.debug("LocalMediaStorage createAlbum")

        passcodeStorage.systemCallOnScreen = true
        
        var assetCollectionPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { [weak self] success, error in
            self?.passcodeStorage.systemCallOnScreen = false
            
            if success, let localIdentifier = assetCollectionPlaceholder?.localIdentifier {
                log.debug("LocalMediaStorage createAlbum PHPhotoLibrary performChanges success")

                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
                completion(collectionFetchResult.firstObject)
            }
        })
    }
    
    func loadAlbum(_ name: String) -> PHAssetCollection? {
        log.debug("LocalMediaStorage loadAlbum")

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return fetchResult.firstObject
    }
    
    // MARK: Copy Assets
    
    func copyAssetToDocument(asset: PHAsset) -> URL? {
        log.debug("LocalMediaStorage copyAssetToDocument")
        
        switch  asset.mediaType {
        case .image:
            return copyImageAsset(asset: asset)
        
        case .video:
            return copyVideoAsset(asset: asset)
        
        default:
            return nil
        }
    }
    
    func copyVideoAsset(asset: PHAsset) -> URL {
        log.debug("LocalMediaStorage copyVideoAsset")

        var url = LocalMediaStorage.defaultUrl
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: self.photoManger,
                                                  asset: asset) { avAsset, aVAudioMix, Dict in
                                                    
                                                    if let urlToFile = (avAsset as? AVURLAsset)?.url {
                                                        let file = UUID().uuidString
                                                        url = Device.tmpFolderUrl(withComponent: file)

                                                        self.streamReaderWrite.copyFile(from: urlToFile, to: url, completion: { result in
                                                            switch result {
                                                            case .success(_):
                                                                break
                                                            case .failed(let error):
                                                                UIApplication.showErrorAlert(message: error.description)
                                                            }
                                                            semaphore.signal()
                                                        })
                                                    } else {
                                                        semaphore.signal()
                                                    }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return url
    }
    
    func copyImageAsset(asset: PHAsset) -> URL {
        log.debug("LocalMediaStorage copyImageAsset")
        
        var url = LocalMediaStorage.defaultUrl
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalImageOperation(photoManager: self.photoManger,
                                                  asset: asset) { data, string, orientation, dict in
                                                    let file = UUID().uuidString
                                                    url = Device.tmpFolderUrl(withComponent: file)
                                                    do {
                                                        try data?.write(to: url)
                                                        semaphore.signal()
                                                    } catch {
                                                        print(error.description)
                                                        semaphore.signal()
                                                    }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return url
    }

    // MARK: Asset info

    
    func fullInfoAboutAsset(asset: PHAsset) -> AssetInfo {

        switch asset.mediaType {
        case .image:
            return fullInfoAboutImageAsset(asset: asset)

        case . video:
            return fullInfoAboutVideoAsset(asset: asset)
        
        default:
            return AssetInfo(libraryAsset: asset)
        }
    }
    
    private func compactInfoAboutAsset(asset: PHAsset) -> AssetInfo {
        
        switch asset.mediaType {
        case .image:
            return compactInfoAboutImageAsset(asset: asset)
            
        case . video:
            return compactInfoAboutVideoAsset(asset: asset)
            
        default:
            return AssetInfo(libraryAsset: asset)
        }
    }
    
    private func compactInfoAboutVideoAsset(asset: PHAsset) -> AssetInfo {
        
        var assetInfo = AssetInfo(libraryAsset: asset)
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetCompactVideoOperation(photoManager: self.photoManger, asset: asset) { avAsset, aVAudioMix, dict in
            
            self.dispatchQueue.async {
                let failCompletion = {
                    print("VIDEO_LOCAL_ITEM: \(asset.localIdentifier) is in iCloud")
                    assetInfo.isValid = false
                    semaphore.signal()
                }
                
                guard let dict = dict else {
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                if let error = dict[PHImageErrorKey] as? NSError {
                    print(error.localizedDescription)
                    failCompletion()
                    return
                }
                
                ///it seems that PHImageResultIsInCloudKey says nothing about local video availability
//                if let inCloud = dict[PHImageResultIsInCloudKey] as? NSNumber, inCloud.boolValue {
//                    failCompletion()
//                    return
//                }
                
                if let isDegraded = dict[PHImageResultIsDegradedKey] as? NSNumber, isDegraded.boolValue  {
                    semaphore.signal()
                    return
                }
                
                if let urlToFile = (avAsset as? AVURLAsset)?.url {
                    do {
                        assetInfo.url = urlToFile
                        if let size = try FileManager.default.attributesOfItem(atPath: urlToFile.path)[.size] as? NSNumber {
                            assetInfo.size = size.int64Value
                        }
                        
                        if let name = asset.originalFilename {
                            assetInfo.name = name
                        }
                        debugPrint("ORIGINAL NAME VIDEO is \(assetInfo.name)")
                        semaphore.signal()
                    } catch {
                        failCompletion()
                        return
                    }
                } else {
                    failCompletion()
                    return
                }
            }
            
        }
        
        getDetailQueue.addOperation(operation)
        /// added timeout bcz callback from "requestAVAsset(forVideo" may not come
        _ = semaphore.wait(timeout: .now() + .seconds(40))
        return assetInfo
    }
    
    func compactInfoAboutImageAsset(asset: PHAsset) -> AssetInfo {
        
        var assetInfo = AssetInfo(libraryAsset: asset)
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetCompactImageOperation(photoManager: self.photoManger, asset: asset) { data, string, orientation, dict in
            self.dispatchQueue.async {
                let failCompletion = {
                    print("IMAGE_LOCAL_ITEM: \(asset.localIdentifier) is in iCloud")
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                guard let dict = dict else {
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                
                if let error = dict[PHImageErrorKey] as? NSError {
                    print(error.localizedDescription)
                    failCompletion()
                    return
                }
                
                if let inCloud = dict[PHImageResultIsInCloudKey] as? NSNumber, inCloud.boolValue {
                    failCompletion()
                    return
                }
                
                if let isDegraded = dict[PHImageResultIsDegradedKey] as? NSNumber, isDegraded.boolValue  {
                    semaphore.signal()
                    return
                }
                
                if let dataValue = data {
                    if let name = asset.originalFilename {
                        assetInfo.name = name
                    }
                    if let unwrapedUrl = dict["PHImageFileURLKey"] as? URL {
                        assetInfo.url = unwrapedUrl
                    }
                    assetInfo.size = Int64(dataValue.count)
                    semaphore.signal()
                } else {
                    failCompletion()
                    return
                }
            }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return assetInfo
    }
    
    
    func fullInfoAboutVideoAsset(asset: PHAsset) -> AssetInfo {
        
        var assetInfo = AssetInfo(libraryAsset: asset)
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: self.photoManger, asset: asset) { avAsset, aVAudioMix, dict in
            
            self.dispatchQueue.async {
                let failCompletion = {
                    print("VIDEO_LOCAL_ITEM: \(asset.localIdentifier) is in iCloud")
                    assetInfo.isValid = false
                    semaphore.signal()
                }
                
                guard let dict = dict else {
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                if let error = dict[PHImageErrorKey] as? NSError {
                    print(error.localizedDescription)
                    failCompletion()
                    return
                }
                
//                if let inCloud = dict[PHImageResultIsInCloudKey] as? NSNumber, inCloud.boolValue {
//                    failCompletion()
//                    return
//                }
                
                if let isDegraded = dict[PHImageResultIsDegradedKey] as? NSNumber, isDegraded.boolValue  {
                    return
                }
                
                if let urlToFile = (avAsset as? AVURLAsset)?.url {
                    do {
                        assetInfo.url = urlToFile
                        if let size = try FileManager.default.attributesOfItem(atPath: urlToFile.path)[.size] as? NSNumber {
                            assetInfo.size = size.int64Value
                        }
                        
                        if let name = asset.originalFilename {
                            assetInfo.name = name
                        }
                        debugPrint("ORIGINAL NAME VIDEO is \(assetInfo.name)")
                        semaphore.signal()
                    } catch {
                        failCompletion()
                        return
                    }
                } else {
                    failCompletion()
                    return
                }
            }
            
        }
        
        getDetailQueue.addOperation(operation)
        /// added timeout bcz callback from "requestAVAsset(forVideo" may not come
        _ = semaphore.wait(timeout: .now() + .seconds(40))
        return assetInfo
    }
    
    func fullInfoAboutImageAsset(asset: PHAsset) -> AssetInfo {
        
        var assetInfo = AssetInfo(libraryAsset: asset)
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetOriginalImageOperation(photoManager: self.photoManger, asset: asset) { data, string, orientation, dict in
            self.dispatchQueue.async {
                let failCompletion = {
                    print("IMAGE_LOCAL_ITEM: \(asset.localIdentifier) is in iCloud")
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                guard let dict = dict else {
                    assetInfo.isValid = false
                    semaphore.signal()
                    return
                }
                
                
                if let error = dict[PHImageErrorKey] as? NSError {
                    print(error.localizedDescription)
                    failCompletion()
                    return
                }
                
                if let inCloud = dict[PHImageResultIsInCloudKey] as? NSNumber, inCloud.boolValue {
                    failCompletion()
                    return
                }
                
                if let isDegraded = dict[PHImageResultIsDegradedKey] as? NSNumber, isDegraded.boolValue  {
                    return
                }
                
                if let dataValue = data {
                    if let name = asset.originalFilename {
                        assetInfo.name = name
                    }
                    if let unwrapedUrl = dict["PHImageFileURLKey"] as? URL {
                        assetInfo.url = unwrapedUrl
                    }
                    assetInfo.size = Int64(dataValue.count)
                    semaphore.signal()
                } else {
                    failCompletion()
                    return
                }
            }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return assetInfo
    }
    
    
    func cancelRequest(asset: PHAsset) {
        if let all: [GetImageOperation] =  queue.operations as? [GetImageOperation] {
            let forAssets = all.filter { $0.asset == asset }
            forAssets.forEach { $0.cancel() }
        }
    }
}

typealias PhotoManagerCallBack = (UIImage?, [AnyHashable: Any]?) -> Void

typealias PhotoManagerOriginalVideoCallBack = (AVAsset?, AVAudioMix?, [AnyHashable: Any]?) -> Void

typealias PhotoManagerOriginalCallBack = (Data?, String?, UIImageOrientation, [AnyHashable: Any]?) -> Void


class GetImageOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: (UIImage?, [AnyHashable: Any]?) -> Void
    
    let asset: PHAsset
    
    let targetSize: CGSize
    
    init(photoManager: PHImageManager, asset: PHAsset, targetSize: CGSize, callback: @escaping PhotoManagerCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        self.targetSize = targetSize
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .none
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        photoManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: options,
                                  resultHandler: callback)
    }
}


class GetOriginalImageOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: PhotoManagerOriginalCallBack
    
    let asset: PHAsset
    
    init(photoManager: PHImageManager, asset: PHAsset, callback: @escaping PhotoManagerOriginalCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
//        options.isSynchronous = true
        
        photoManager.requestImageData(for: asset, options: options, resultHandler: callback)
    }
}

class GetOriginalVideoOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: PhotoManagerOriginalVideoCallBack
    
    let asset: PHAsset
    
    init(photoManager: PHImageManager, asset: PHAsset, callback: @escaping PhotoManagerOriginalVideoCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat

        photoManager.requestAVAsset(forVideo: asset, options: options, resultHandler: callback)
    }
}

class GetCompactImageOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: PhotoManagerOriginalCallBack
    
    let asset: PHAsset
    
    init(photoManager: PHImageManager, asset: PHAsset, callback: @escaping PhotoManagerOriginalCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
        
        photoManager.requestImageData(for: asset, options: options, resultHandler: callback)
    }
}

class GetCompactVideoOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: PhotoManagerOriginalVideoCallBack
    
    let asset: PHAsset
    
    init(photoManager: PHImageManager, asset: PHAsset, callback: @escaping PhotoManagerOriginalVideoCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .fastFormat
        
        photoManager.requestAVAsset(forVideo: asset, options: options, resultHandler: callback)
    }
}

class AddAssetToCollectionOperation: AsyncOperation {
    
    let albumName: String
    let assetIdentifier: String
    let mediaStorage = LocalMediaStorage.default
    
    init(albumName: String, assetIdentifier: String) {
        self.albumName = albumName
        self.assetIdentifier = assetIdentifier
        super.init()
    }
    
    override func workItem() {
        if let collection = mediaStorage.loadAlbum(albumName) {
            mediaStorage.add(asset: assetIdentifier, to: collection)
            markFinished()
        } else {
            mediaStorage.createAlbum(albumName, completion: { [weak self] collection in
                if let collection = collection, let `self` = self {
                    self.mediaStorage.add(asset: self.assetIdentifier, to: collection)
                    self.markFinished()
                }
            })
        }
    }

}
