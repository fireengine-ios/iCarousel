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
    var url = LocalMediaStorage.defaultUrl
    var size = Int64(0)
    var name = ""
    var md5: String {
        if !name.isEmpty && size > 0 {
            return String(format: "%@%i", name, size)
        }
        return LocalMediaStorage.noneMD5
    }
}


protocol LocalMediaStorageProtocol {
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func getAllImagesAndVideoAssets() -> [PHAsset]
    
    func removeAssets(deleteAsset: [PHAsset], success: FileOperation?, fail: FailResponse?)
    
    func copyAssetToDocument(asset: PHAsset) -> URL
    
    func fullInfoAboutAsset(asset: PHAsset) -> AssetInfo
}

class LocalMediaStorage: NSObject, LocalMediaStorageProtocol {
    
    static let `default` = LocalMediaStorage()
        
    private let photoManger = PHImageManager.default()
    
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private lazy var streamReaderWrite = StreamReaderWriter()
    
    private let queue = OperationQueue()
    
    private let getDetailQueue = OperationQueue()
    
    static let notificationPhotoLibraryDidChange = NSNotification.Name(rawValue: "notificationPhotoLibraryDidChange")
    
    static let defaultUrl = URL(string: "http://Not.url.com")!
    
    static let noneMD5 = "NONE MD5"
    
    var assetsCache = AssetsСache()
    
    private override init() {
        queue.maxConcurrentOperationCount = 1
        getDetailQueue.maxConcurrentOperationCount = 1
        
        super.init()
//        askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] (accessGranted, _) in
//            if accessGranted, let `self` = self {
                self.photoLibrary.register(self)
//            }
//        }
    }
    
    func photoLibraryIsAvailible() -> Bool {
        log.debug("LocalMediaStorage photoLibraryIsAvailible")

        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
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
        log.debug("LocalMediaStorage showAccessAlert")

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
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
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
            
            let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            
            var albums = [AlbumItem]()
            
            [album, smartAlbum].forEach { album in
                album.enumerateObjects { object, index, stop in
                    if object.photosCount > 0 || object.videosCount > 0 {
                        let item = AlbumItem(uuid: object.localIdentifier,
                                             name: object.localizedTitle,
                                             creationDate: nil,
                                             lastModifiDate: nil,
                                             fileType: .photoAlbum,
                                             syncStatus: .unknown,
                                             isLocalItem: true)
                        item.imageCount = object.photosCount + object.videosCount

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
            completion(albums)
        }
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
        
        let scalling: PhotoManagerCallBack = { input, dict in
            let newImg = input?.resizeImage(rect: contentSize)
            
            DispatchQueue.main.async {
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
                if let item = item, let assetIdentifier = assetPlaceholder?.localIdentifier {
                    self?.merge(asset: assetIdentifier, with: item)
                }
                if let album = album, let assetPlaceholder = assetPlaceholder {
                    self?.add(asset: assetPlaceholder.localIdentifier, to: album)
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
    
    private func merge(asset assetIdentifier: String, with item: WrapData) {
        
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject {
   
            let wrapData = WrapData(asset: asset)
            wrapData.copyFileData(from: item)
            
            let context = CoreDataStack.default.backgroundContext
            context.perform {
                let mediaItem: MediaItem
                if let existingMediaItem = CoreDataStack.default.mediaItemByUUIDs(uuidList: [item.uuid]).first {
                    mediaItem = existingMediaItem
                } else {
                    mediaItem = MediaItem(wrapData: wrapData, context: context)
                }
                
                
                mediaItem.localFileID = assetIdentifier
                CoreDataStack.default.updateSavedItems(savedItems: [mediaItem], remoteItems: [item], context: context)
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
//                try data.write(to: fileUrl)
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
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
    
    func copyAssetToDocument(asset: PHAsset) -> URL {
        log.debug("LocalMediaStorage copyAssetToDocument")
        
        switch  asset.mediaType {
        case .image:
            return copyImageAsset(asset: asset)
        
        case .video:
            return copyVideoAsset(asset: asset)
        
        default:
            return LocalMediaStorage.defaultUrl
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
                                                                if let message = (error as? CustomErrors)?.errorDescription {
                                                                    UIApplication.showErrorAlert(message: message)
                                                                } else {
                                                                    UIApplication.showErrorAlert(message: error.localizedDescription)
                                                                }
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
                                                        semaphore.signal()
                                                    }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return url
    }
    
    
    // MARK: Asset info

    
    func fullInfoAboutAsset(asset: PHAsset) -> AssetInfo {
        log.debug("LocalMediaStorage fullInfoAboutAsset")

        switch asset.mediaType {
        case .image:
            return fullInfoAboutImageAsset(asset: asset)
            
        case . video:
            return fullInfoAboutVideoAsset(asset: asset)
        
        default:
            return AssetInfo()
        }
    }
    
    func fullInfoAboutVideoAsset(asset: PHAsset) -> AssetInfo {
        log.debug("LocalMediaStorage fullInfoAboutVideoAsset")

        var assetInfo = AssetInfo()
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: self.photoManger, asset: asset) { avAsset, aVAudioMix, dict in
            if let error = dict?[PHImageErrorKey] as? NSError, let inCloud = dict?[PHImageResultIsInCloudKey] as? Bool, inCloud {
                print(error.description)
                semaphore.signal()
                return
            }
            
            if let urlToFile = (avAsset as? AVURLAsset)?.url {
                do {
                    assetInfo.url = urlToFile
                    assetInfo.size = try (FileManager.default.attributesOfItem(atPath: urlToFile.path)[.size] as! NSNumber).int64Value
                    if let name = asset.originalFilename {
                        assetInfo.name = name
                    }
                    semaphore.signal()
                } catch {
                    semaphore.signal()
                }
            } else {
                semaphore.signal()
            }
        }
    
        getDetailQueue.addOperation(operation)
        /// added timeout bcz callback from "requestAVAsset(forVideo" may not come
        _ = semaphore.wait(timeout: .now() + .seconds(40))
        return assetInfo
    }
    
    func fullInfoAboutImageAsset(asset: PHAsset) -> AssetInfo {
        log.debug("LocalMediaStorage fullInfoAboutImageAsset")
        
        var assetInfo = AssetInfo()
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetOriginalImageOperation(photoManager: self.photoManger,
                                                  asset: asset) { data, string, orientation, dict in
                                                    if let error = dict?[PHImageErrorKey] as? NSError, let inCloud = dict?[PHImageResultIsInCloudKey] as? Bool, inCloud {
                                                        print(error.description)
                                                        semaphore.signal()
                                                        return
                                                    }
            if let wrapDict = dict, let dataValue = data {
                if let name = asset.originalFilename {
                    assetInfo.name = name
                }
                if let unwrapedUrl = wrapDict["PHImageFileURLKey"] as? URL {
                    assetInfo.url = unwrapedUrl
                }
                assetInfo.size = Int64(dataValue.count)
                
                semaphore.signal()
            } else {
                semaphore.signal()
            }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return assetInfo
    }
    
    
    func cancelRequest(asset: PHAsset) {
        log.debug("LocalMediaStorage cancelRequest")

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
        options.isSynchronous = true
        
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
        options.isSynchronous = true
        
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
