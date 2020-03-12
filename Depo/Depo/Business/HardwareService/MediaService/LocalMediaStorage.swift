//
//  FilesLocalDataSource.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import Photos
import SwiftyGif

typealias PhotoLibraryGranted = (_ granted: Bool, _ status: PHAuthorizationStatus) -> Void

typealias FileDataSorceImg = (_ image: UIImage?) -> Void

typealias FileDataSorceData = (_ image: Data?) -> Void

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
    
    /// if PHImageManager had been inited once (e.g. by "PHImageManager.default()")
    /// when user denied access to photos ("PHPhotoLibrary.authorizationStatus() == .authorized")
    /// than app will crash when application will receive memory warning
    /// (can be tested in simulator by "Debug - Simulate Memory Warning")
    /// with message "This application is not allowed to access Photo data"
    /// https://stackoverflow.com/a/50663778/5893286
    private lazy var photoManager: PHImageManager? = {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            return nil
        }
        
        return PHImageManager.default()
    }()
    
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private lazy var operationsService = MediaItemOperationsService.shared
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    
    private lazy var streamReaderWrite = StreamReaderWriter()
    
    private let queue = OperationQueue()
    
    private let getDetailQueue = OperationQueue()
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.localMediaStorage, attributes: .concurrent)
    
    static let defaultUrl = URL(string: "http://Not.url.com")!
    
    static let noneMD5 = "NONE MD5"
    
    private (set) var isWaitingForPhotoPermission = false
    
    var assetsCache = AssetsCache()
    
    private override init() {
        queue.maxConcurrentOperationCount = 1
        
        super.init()
        guard photoLibraryIsAvailible() else {
            return
        }
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
        debugLog("LocalMediaStorage clearTemporaryFolder")
        
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
        debugLog("LocalMediaStorage showAccessAlert")

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
        isWaitingForPhotoPermission = true
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            photoLibrary.register(self)
            if (Device.operationSystemVersionLessThen(10)) {
                PHPhotoLibrary.requestAuthorization({ [weak self] authStatus in
                    let isAuthorized = authStatus == .authorized
                    self?.isWaitingForPhotoPermission = false
                    completion(isAuthorized, authStatus)
                })
            } else {
                isWaitingForPhotoPermission = false
                completion(true, status)
            }
            AnalyticsPermissionNetmeraEvent.sendPhotoPermissionNetmeraEvents(true)
        case .notDetermined, .restricted:
            passcodeStorage.systemCallOnScreen = true
            PHPhotoLibrary.requestAuthorization({ [weak self] authStatus in
                guard let `self` = self else {
                    return
                }
                
                self.passcodeStorage.systemCallOnScreen = false
                let isAuthorized = authStatus == .authorized
                if isAuthorized {
                    self.photoLibrary.register(self)
                }
                AnalyticsPermissionNetmeraEvent.sendPhotoPermissionNetmeraEvents(isAuthorized)
                self.isWaitingForPhotoPermission = false
                completion(isAuthorized, authStatus)
            })
        case .denied:
            isWaitingForPhotoPermission = false
            completion(false, status)
            if redirectToSettings {
                DispatchQueue.main.async {
                    AnalyticsPermissionNetmeraEvent.sendPhotoPermissionNetmeraEvents(false)
                    self.showAccessAlert()
                }
            }
        }
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    func getAllImagesAndVideoAssets() -> [PHAsset] {
        assetsCache.dropAll()
        debugLog("LocalMediaStorage getAllImagesAndVideoAssets")

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
        debugLog("LocalMediaStorage getAllAlbums")
        askPermissionForPhotoFramework(redirectToSettings: true) { [weak self] accessGranted, _ in
            guard accessGranted else {
                completion([])
                return
            }
            
            DispatchQueue.global().async {
                let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                
                var albums = [AlbumItem]()
                
                let dispatchGroup = DispatchGroup()
                [album, smartAlbum].forEach { album in
                    album.enumerateObjects { object, index, stop in
                        dispatchGroup.enter()
                        self?.numberOfItems(in: object) { itemsCount, fromCoreData  in
                            if itemsCount > 0 {
                                let item = AlbumItem(uuid: object.localIdentifier,
                                                     name: object.localizedTitle,
                                                     creationDate: nil,
                                                     lastModifiDate: nil,
                                                     fileType: .photoAlbum,
                                                     syncStatus: .unknown,
                                                     isLocalItem: true)
                                if fromCoreData {
                                    item.imageCount = itemsCount
                                }
                                
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                                
                                if let asset = PHAsset.fetchAssets(in: object, options: fetchOptions).firstObject,
                                    let info = self?.compactInfoAboutAsset(asset: asset), info.isValid {
                                    
                                    item.preview = WrapData(asset: asset)
                                    albums.append(item)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    /// Sort our albums by name AZ
                    albums.sort(by: {
                        if let firstSortName = $0.name, let secondSortName = $1.name {
                            return firstSortName < secondSortName
                        } else {
                            assertionFailure()
                            return true
                        }
                    })
                    completion(albums)
                }
            }
        }
    }
    
    func getLocalAlbums(completion: @escaping (_ albums: [PHAssetCollection]) -> Void) {
        askPermissionForPhotoFramework(redirectToSettings: true) { accessGranted, _ in
            guard accessGranted else {
                completion([])
                return
            }
            
            DispatchQueue.global().async {
                let fetchOptions = PHFetchOptions()
                let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                
                var albums = [PHAssetCollection]()
                
                let dispatchGroup = DispatchGroup()
                [album, smartAlbum].forEach { album in
                    album.enumerateObjects { object, index, stop in
                        dispatchGroup.enter()
                        let assets = PHAsset.fetchAssets(in: object, options: fetchOptions)
                        if assets.firstObject != nil {
                            albums.append(object)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(albums)
                }
            }
        }
    }
    
    private func numberOfItems(in album: PHAssetCollection, completion: @escaping (_ value: Int, _ fromCoreData: Bool) -> Void) {
        guard !CacheManager.shared.isProcessing else {
            completion(album.photosCount + album.videosCount, false)
            return
        }
        let assets = PHAsset.fetchAssets(in: album, options: PHFetchOptions())
        let array = assets.objects(at: IndexSet(0..<assets.count))
        let context = coreDataStack.newChildBackgroundContext
        operationsService.listAssetIdAlreadySaved(allList: array, context: context) { ids in
            completion(ids.count, true)
        }
    }
    
    // MARK: Image
    
    func getPreviewMaxImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        debugLog("LocalMediaStorage getPreviewMaxImage")

        getImage(asset: asset,
                 contentSize: PHImageManagerMaximumSize,
                 image: image)
    }
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        debugLog("LocalMediaStorage getPreviewImage")

        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 300, height: 300),
                 image: image)
    }
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg) {
        debugLog("LocalMediaStorage getBigImageFromFile")

        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 768.0, height: 768.0),
                 image: image)
    }
    
    func getImage(asset: PHAsset, contentSize: CGSize, convertToSize: CGSize, image: @escaping FileDataSorceImg) {
        debugLog("LocalMediaStorage getImage")
        
        guard let photoManager = photoManager else {
            image(nil)
            return
        }
        
        let scalling: PhotoManagerCallBack = { [weak self] input, dict in
            self?.dispatchQueue.async {
                let newImg = input?.resizeImage(rect: contentSize)
                    image(newImg)
                
            }
        }
        
        let operation = GetImageOperation(photoManager: photoManager,
                                          asset: asset,
                                          targetSize: convertToSize,
                                          callback: scalling)
        queue.addOperation(operation)
    }
    
    func getImage(asset: PHAsset, contentSize: CGSize, image: @escaping FileDataSorceImg) {
        debugLog("LocalMediaStorage getImage")
        
        guard let photoManager = photoManager else {
            image(nil)
            return
        }

        let callBack: PhotoManagerCallBack = { newImg, _ in
            DispatchQueue.main.async {
                image(newImg)
            }
        }
        let operation = GetImageOperation(photoManager: photoManager,
                                          asset: asset,
                                          targetSize: contentSize,
                                          callback: callBack)
        queue.addOperation(operation)
    }
    
    func getImageData(asset: PHAsset, data: @escaping FileDataSorceData) {
        debugLog("LocalMediaStorage getGifImage")
        
        guard let photoManager = photoManager else {
            data(nil)
            return
        }

        let callBack: PhotoManagerOriginalCallBack = { imageData, _, _, _ in
            DispatchQueue.main.async {
                data(imageData)
            }
        }
        let operation = GetOriginalImageOperation(photoManager: photoManager, asset: asset, callback: callBack)
        queue.addOperation(operation)
    }
    
    // MARK: insert remove Asset
    
    func removeAssets(deleteAsset: [PHAsset], success: FileOperation?, fail: FailResponse?) {
        debugLog("LocalMediaStorage removeAssets")

        guard photoLibraryIsAvailible() else {
            fail?(.failResponse(nil))
            return
        }
        
        passcodeStorage.systemCallOnScreen = true
        
        PHPhotoLibrary.shared().performChanges({
            
            let listToDelete = NSArray(array: deleteAsset)
            
            PHAssetChangeRequest.deleteAssets(listToDelete)
            
        }, completionHandler: { [weak self] status, error in
            debugLog("LocalMediaStorage removeAssets PHPhotoLibrary performChanges success")
            
            self?.passcodeStorage.systemCallOnScreen = false
            
            if status {
                success?()
            } else if let error = error {
                debugLog("LocalMediaStorage removeAssets PHPhotoLibrary fail")
                fail?(.error(error))
            } else {
                debugLog("LocalMediaStorage removeAssets PHPhotoLibrary cancelled without error")
                // cancelled
                // ios 13 beta doesn't return error
                fail?(.string(TextConstants.errorUnknown))
            }
        })
    }
    
    /*
     * if album = nil the item will be saved to camera roll
     * 
     */
    func appendToAlbum(fileUrl: URL, type: PHAssetMediaType, album: String?, item: WrapData? = nil, success: FileOperation?, fail: FailResponse?) {
        debugLog("LocalMediaStorage appendToAlboum")
        
        saveToGallery(fileUrl: fileUrl, type: type) { [weak self] response in
            switch response {
            case .success(let placeholder):
                if let album = album, let assetPlaceholder = placeholder {
                    self?.add(asset: assetPlaceholder.localIdentifier, to: album)
                    success?()
                } else if let item = item, let assetIdentifier = placeholder?.localIdentifier {
                    self?.merge(asset: assetIdentifier, with: item, success: success, fail: fail)
                }
            case .failed(let error):
                fail?(.error(error))
            }
        }
    }
    
    func saveToGallery(fileUrl: URL, type: PHAssetMediaType, handler: @escaping ResponseHandler<PHObjectPlaceholder?>) {
        debugLog("LocalMediaStorage saveToGallery")

        guard photoLibraryIsAvailible() else {
            handler(.failed(ErrorResponse.string("Photo libraryr is unavailable")))
            return
        }
        
        passcodeStorage.systemCallOnScreen = true
        
        var assetPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            switch type {
                case .image:
                    assetPlaceholder = self?.createRequestAppendImageToAlbum(fileUrl: fileUrl)
                case .video:
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                    assetPlaceholder = request?.placeholderForCreatedAsset
                default:
                    handler(.failed(ErrorResponse.string("Only for photo & Video")))
            }
            
        }, completionHandler: { [weak self] status, error in
            self?.passcodeStorage.systemCallOnScreen = false
            
            if let error = error {
                handler(.failed(ErrorResponse.error(error)))
                return
            }
            
            handler(.success(assetPlaceholder))
        })
    }
    
    var addAssetToCollectionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func saveFilteredImage(filteredImage: UIImage, originalImage: Item, success: VoidHandler?, fail: FailResponse?) {
        guard photoLibraryIsAvailible() else {
            fail?(.failResponse(nil))
            return
        }
        var localTempoID = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
            guard let localID = request.placeholderForCreatedAsset?.localIdentifier else {
                fail?(.failResponse(nil))
                return
            }
            localTempoID = localID
        }, completionHandler: { [weak self] status, error in
            self?.merge(asset: localTempoID, with: originalImage, isFilteredItem: true, success: success, fail: fail)
        })
        
    }
    
    private func merge(asset assetIdentifier: String, with item: WrapData, isFilteredItem: Bool = false, success: VoidHandler? = nil, fail: FailResponse? = nil) {
        guard photoLibraryIsAvailible() else {
            fail?(.failResponse(nil))
            return
        }
        
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject else {
            assertionFailure()
            fail?(.failResponse(nil))
            return
        }
            
        let mediaItemService = MediaItemOperationsService.shared
        LocalMediaStorage.default.assetsCache.append(list: [asset])
        
        // call append to get the completion and to be sure that local item is saved in our db
        mediaItemService.append(localMediaItems: [asset]) {
            let context = self.coreDataStack.newChildBackgroundContext
            mediaItemService.mediaItems(by: asset.localIdentifier, context: context, mediaItemsCallBack: { items in
                guard let savedLocalItem = items.first else {
                    assertionFailure()
                    fail?(.failResponse(nil))
                    return
                }
                // manually change some  properties
                savedLocalItem.trimmedLocalFileID = item.getFisrtUUIDPart()
                savedLocalItem.syncStatusValue = SyncWrapperedStatus.synced.valueForCoreDataMapping()
                if isFilteredItem {
                    savedLocalItem.isFiltered = true
                }
                
                var userObjectSyncStatus = Set<MediaItemsObjectSyncStatus>()
                if let unwrapedSet = savedLocalItem.objectSyncStatus as? Set<MediaItemsObjectSyncStatus> {
                    userObjectSyncStatus = unwrapedSet
                }
                SingletonStorage.shared.getUniqueUserID(success: {
                    currentUserID in
                    context.perform {
                        savedLocalItem.objectSyncStatus = NSSet(set: userObjectSyncStatus)
                        userObjectSyncStatus.insert(MediaItemsObjectSyncStatus(userID: currentUserID, context: context))
                        MediaItemOperationsService.shared.updateRelationsAfterMerge(with: item.uuid, localItem: savedLocalItem, context: context, completion: {
                            self.coreDataStack.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                                success?()
                            })
                        })
                    }
                }, fail: { error in
                    fail?(error)
                })
            })
        }
    }
    
    fileprivate func add(asset assetIdentifier: String, to album: String) {
        askPermissionForPhotoFramework(redirectToSettings: true, completion: { [weak self] accessGranted, _ in
            if accessGranted {
                let operation = AddAssetToCollectionOperation(albumName: album, assetIdentifier: assetIdentifier)
                self?.addAssetToCollectionQueue.addOperation(operation)
            }
        })
    }
    
    fileprivate func createRequestAppendImageToAlbum(fileUrl: URL) -> PHObjectPlaceholder? {
        let request = PHAssetCreationRequest.forAsset()
        request.addResource(with: .photo, fileURL: fileUrl, options: nil)
        return request.placeholderForCreatedAsset
    }
    
    fileprivate func add(asset assetIdentifier: String, to collection: PHAssetCollection) {
        guard photoLibraryIsAvailible() else {
            return
        }
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
        guard photoLibraryIsAvailible() else {
            completion(nil)
            return
        }
        debugLog("LocalMediaStorage createAlbum")

        passcodeStorage.systemCallOnScreen = true
        
        var assetCollectionPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { [weak self] success, error in
            self?.passcodeStorage.systemCallOnScreen = false
            
            if success, let localIdentifier = assetCollectionPlaceholder?.localIdentifier {
                debugLog("LocalMediaStorage createAlbum PHPhotoLibrary performChanges success")

                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
                completion(collectionFetchResult.firstObject)
            }
        })
    }
    
    func loadAlbum(_ name: String) -> PHAssetCollection? {
        debugLog("LocalMediaStorage loadAlbum")
        guard photoLibraryIsAvailible() else {
            return nil
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return fetchResult.firstObject
    }
    
    // MARK: Copy Assets
    
    func copyAssetToDocument(asset: PHAsset) -> URL? {
        debugLog("LocalMediaStorage copyAssetToDocument")
        
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
        debugLog("LocalMediaStorage copyVideoAsset")

        var url = LocalMediaStorage.defaultUrl
        
        guard let photoManager = photoManager else {
            return url
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: photoManager,
                                                  asset: asset) { [weak self] avAsset, aVAudioMix, Dict in
                                                    
                                                    if let urlToFile = (avAsset as? AVURLAsset)?.url {
                                                        let file = UUID().uuidString
                                                        url = Device.tmpFolderUrl(withComponent: file)

                                                        self?.streamReaderWrite.copyFile(from: urlToFile, to: url, completion: { result in
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
        debugLog("LocalMediaStorage copyImageAsset")
        
        var url = LocalMediaStorage.defaultUrl
        
        guard let photoManager = photoManager else {
            return url
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalImageOperation(photoManager: photoManager,
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
            var info = AssetInfo(libraryAsset: asset)
            info.isValid = false
            return info
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
        
        guard let photoManager = photoManager else {
            return assetInfo
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetCompactVideoOperation(photoManager: photoManager, asset: asset) { avAsset, aVAudioMix, dict in
            
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
        
        guard let photoManager = photoManager else {
            return assetInfo
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetCompactImageOperation(photoManager: photoManager, asset: asset) { data, string, orientation, dict in
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
                    /// there is no PHImageFileURLKey in iOS 13.
                    /// more solutions at https://stackoverflow.com/q/57202965/5893286
                    ///
                    /// parsing example of debugDescription:
                    ///fileURL: file:///var/mobile/Media/DCIM/101APPLE/IMG_1490.HEIC
                    ///width: 3024
                    if #available(iOS 13, *),
                        let filePath = asset.resource?.debugDescription.slice(from: "fileURL: ", to: "\n    width"),
                        let fileUrl = URL(string: filePath)
                    {
                        assetInfo.url = fileUrl
                    } else if let unwrapedUrl = dict["PHImageFileURLKey"] as? URL {
                        assetInfo.url = unwrapedUrl
                    } else {
                        assertionFailure("should not be called")
                    }
                    
                    if let name = asset.originalFilename {
                        assetInfo.name = name
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
        
        guard let photoManager = photoManager else {
            return assetInfo
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: photoManager, asset: asset) { avAsset, aVAudioMix, dict in
            
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
                        } else {
                            failCompletion()
                            return
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
        
        guard let photoManager = photoManager else {
            return assetInfo
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetOriginalImageOperation(photoManager: photoManager, asset: asset) { data, string, orientation, dict in
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
                    /// there is no PHImageFileURLKey in iOS 13.
                    /// more solutions at https://stackoverflow.com/q/57202965/5893286
                    ///
                    /// parsing example of debugDescription:
                    ///fileURL: file:///var/mobile/Media/DCIM/101APPLE/IMG_1490.HEIC
                    ///width: 3024
                    if #available(iOS 13, *),
                        let filePath = asset.resource?.debugDescription.slice(from: "fileURL: ", to: "\n    width"),
                        let fileUrl = URL(string: filePath)
                    {
                        assetInfo.url = fileUrl
                    } else if let unwrapedUrl = dict["PHImageFileURLKey"] as? URL {
                        assetInfo.url = unwrapedUrl
                    } else {
                        assertionFailure("should not be called")
                    }
                    
                    if let name = asset.originalFilename {
                        assetInfo.name = name
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
    
    var requestID: PHImageRequestID?
    
    init(photoManager: PHImageManager, asset: PHAsset, targetSize: CGSize, callback: @escaping PhotoManagerCallBack) {
        
        self.photoManager = photoManager
        self.callback = callback
        self.asset = asset
        self.targetSize = targetSize
        super.init()
    }
    
    override func main() {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback(nil, nil)
            return
        }
        if isCancelled {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .none
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        requestID = photoManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: options,
                                  resultHandler: callback)
    }
    
    override func cancel() {
        super.cancel()
        if let requestID = requestID {
            photoManager.cancelImageRequest(requestID)
        }
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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback(nil, nil, .down, nil)
            return
        }
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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback(nil,nil,nil)
            return
        }
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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback(nil, nil, .down, nil)
            return
        }
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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback(nil, nil, nil)
            return
        }
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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            markFinished()
            return
        }
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
