//
//  FilesLocalDataSource.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import Photos

typealias FileDataSorceImg = (_ image: UIImage?) -> ()

typealias AssetInfo = (url: URL, size: UInt64, md5: String)

typealias AssetsList = (_ assets: [PHAsset] ) -> ()

typealias PermissionType = (_: PHAuthorizationStatus) -> Void


protocol LocalMediaStorageProtocol {
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg)
    
    func appendToAlboum(fileUrl: URL, type:PHAssetMediaType, album:String?, success: FileOperation?, fail: FailResponse?)
    
    func getAllImagesAndVideoAssets() -> [PHAsset]
    
    func removeAssets(deleteAsset: [PHAsset],success: FileOperation?, fail: FailResponse?)
    
    func copyAssetToDocument(asset: PHAsset) -> URL
    
    func fullInfoAboutAsset(asset: PHAsset) -> AssetInfo
}

class LocalMediaStorage: NSObject, LocalMediaStorageProtocol {
    
    static let `default` = LocalMediaStorage()
        
    private let photoManger = PHImageManager.default()
    
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private let queue = OperationQueue()
    
    private let getDetailQueue = OperationQueue()
    
    static let notificationPhotoLibraryDidChange = "notificationPhotoLibraryDidChange"
    
    static let defaultUrl = URL(string: "http://Not.url.com")!
    
    static let noneMD5 = "NONE MD5"
    
    var assetsCache = AssetsСache()
    
    private override init() {
        queue.maxConcurrentOperationCount = 1
        getDetailQueue.maxConcurrentOperationCount = 1
        
        super.init()
        photoLibrary.register(self)
    }
    
    func photoIsAvalible() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
    }
    
    func askPermissionForPhotoFramework(_ status:@escaping PermissionType) {
        if photoIsAvalible() {
            status(.authorized)
        } else {
            PHPhotoLibrary.requestAuthorization(status)
        }
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    func getAllImagesAndVideoAssets() -> [PHAsset] {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: options)
        
        var mediaContent = [PHAsset]()
        
        fetchResult.enumerateObjects({ (avalibleAset, index, a) in
            mediaContent.append(avalibleAset)
        })
        
        assetsCache.append(list: mediaContent)
        return mediaContent
    }
    
    
    // MARK: Image
    
    func getPreviewMaxImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        getImage(asset: asset,
                 contentSize: PHImageManagerMaximumSize,
                 image: image)
    }
    
    func getPreviewImage(asset: PHAsset, image: @escaping FileDataSorceImg) {
        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 300, height: 300),
                 image: image)
    }
    
    func getBigImageFromFile(asset: PHAsset, image: @escaping FileDataSorceImg) {
        getImage(asset: asset,
                 contentSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                 convertToSize: CGSize(width: 768.0, height: 768.0),
                 image: image)
    }
    
    func getImage(asset: PHAsset, contentSize: CGSize, convertToSize: CGSize, image: @escaping FileDataSorceImg) -> Void {
        
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
    
    func getImage(asset: PHAsset, contentSize: CGSize, image: @escaping FileDataSorceImg) -> Void {
        let callBack: PhotoManagerCallBack = { (newImg, _) in
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
    
    
    // MARK:  insert remove Asset
    
    func removeAssets(deleteAsset: [PHAsset], success: FileOperation?, fail: FailResponse?) {
        
        PHPhotoLibrary.shared().performChanges({
            
            let listToDelete = NSArray(array: deleteAsset)
            
            PHAssetChangeRequest.deleteAssets(listToDelete)
            
        }, completionHandler: { (status, error) in
            
            if (status) {
                success?()
            } else {
                fail?(.error(error!))
            }
        })
    }
    
    /*
     * if album = nil put to camera rool
     * 
     */
    func appendToAlboum(fileUrl: URL, type:PHAssetMediaType, album:String?, success: FileOperation?, fail: FailResponse?) {
    
        PHPhotoLibrary.shared().performChanges({
            switch type {
                case .image:
                    self.createRequestAppendImageToAlbum(fileUrl: fileUrl)
                case .video:
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                default:
                fail?(.string("Only for photo & Video"))
            }
            
        }, completionHandler: { (status, error) in
            
            if (status) {
                success?()
            } else {
                fail?(.error(error!))
            }
        })
    }
    
    fileprivate func createRequestAppendImageToAlbum(fileUrl: URL) {
        do {
            if let image = try UIImage(data: Data(contentsOf: fileUrl)),
               let data = UIImageJPEGRepresentation(image, 1) {
                try data.write(to: fileUrl)
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
            }
            
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
    // MARK: Copy Assets
    
    func copyAssetToDocument(asset: PHAsset) -> URL {
        
        switch  asset.mediaType {
        case .image:
            return copyImageAsset(asset:asset)
        
        case .video:
            return copyVideoAsset(asset:asset)
        
        default:
            return LocalMediaStorage.defaultUrl
        }
    }
    
    func copyVideoAsset(asset: PHAsset) -> URL {
        var url =  LocalMediaStorage.defaultUrl
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: self.photoManger,
                                                  asset: asset) { (avAsset, aVAudioMix, Dict) in
                                                    
                                                    if let urlToFile = (avAsset as? AVURLAsset)?.url {
                                                        
                                                        do {
                                                            let file = UUID().description
                                                            url = Device.tmpFolderUrl(withComponent: file)
                                                            
                                                          try FileManager.default.copyItem(at: urlToFile, to: url)
                                                            semaphore.signal()
                                                        } catch {
                                                            semaphore.signal()
                                                        }
                                                    }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return url
    }
    
    func copyImageAsset(asset: PHAsset) -> URL {
        
        var url = LocalMediaStorage.defaultUrl
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalImageOperation(photoManager: self.photoManger,
                                                  asset: asset) { (data, string, orientation, dict) in
                                                    let file = UUID().description
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
        switch asset.mediaType {
        case .image:
            return fullInfoAboutImageAsset(asset:asset)
            
        case . video:
            return fullInfoAboutVideoAsset(asset:asset)
        
        default:
            return (url: LocalMediaStorage.defaultUrl, size: 0, md5: LocalMediaStorage.noneMD5)
        }
    }
    
    func fullInfoAboutVideoAsset(asset: PHAsset) -> AssetInfo {
        var url: URL =  LocalMediaStorage.defaultUrl
        var md5: String = LocalMediaStorage.noneMD5
        var size: UInt64 = 0
        let semaphore = DispatchSemaphore(value: 0)
        
        let operation = GetOriginalVideoOperation(photoManager: self.photoManger, asset: asset) { (avAsset, aVAudioMix, Dict) in
            if let urlToFile = (avAsset as? AVURLAsset)?.url {
                do {
                    md5 = MD5().hexMD5fromFileUrl(urlToFile)
                    url = urlToFile
                    size = try (FileManager.default.attributesOfItem(atPath: urlToFile.path)[.size] as! NSNumber).uint64Value
                    semaphore.signal()
                } catch  {
                    semaphore.signal()
                }
            } else {
                semaphore.signal()
            }
        }
    
        getDetailQueue.addOperation(operation)
        /// added timeout bcz callback from "requestAVAsset(forVideo" may not come
        _ = semaphore.wait(timeout: .now() + .seconds(40))
        return (url: url, size: size, md5: md5)
    }
    
    func fullInfoAboutImageAsset(asset: PHAsset) -> AssetInfo {
        
        var url: URL = LocalMediaStorage.defaultUrl
        var md5: String = LocalMediaStorage.noneMD5
        var size: UInt64 = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = GetOriginalImageOperation(photoManager: self.photoManger,
                                                  asset: asset) { (data, string, orientation, dict) in
            if let wrapDict = dict, let dataValue  = data {
                
                url = wrapDict["PHImageFileURLKey"] as! URL
                md5 = MD5().hexMD5fromData(dataValue)
                size = UInt64(dataValue.count)
                semaphore.signal()
            } else {
                semaphore.signal()
            }
        }
        getDetailQueue.addOperation(operation)
        semaphore.wait()
        return (url: url, size: size, md5: md5)
    }
    
    
    func cancelRequest(asset: PHAsset) {
        if let all:[GetImageOperation] =  queue.operations as? [GetImageOperation] {
            let forAssets = all.filter { return $0.asset == asset }
            forAssets.forEach { $0.cancel() }
        }
    }
}

typealias PhotoManagerCallBack = (UIImage?, [AnyHashable : Any]?) -> Swift.Void

typealias PhotoManagerOriginalVideoCallBack = (AVAsset?, AVAudioMix?, [AnyHashable : Any]?) -> Swift.Void

typealias PhotoManagerOriginalCallBack = (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void


class GetImageOperation: Operation {
    
    let photoManager: PHImageManager
    
    let callback: (UIImage?, [AnyHashable : Any]?) -> Swift.Void
    
    let asset: PHAsset
    
    let targetSize: CGSize
    
    init(photoManager: PHImageManager, asset: PHAsset,targetSize: CGSize, callback: @escaping PhotoManagerCallBack) {
        
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
        options.isNetworkAccessAllowed = true
        
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
        options.isNetworkAccessAllowed = true
        photoManager.requestAVAsset(forVideo: asset, options: options, resultHandler: callback)
    }
}
