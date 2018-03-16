//
//  FilesDataSource.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import Photos


protocol PhotoDataSource {
    
    typealias Itemslist = (_ items: [Item]) -> Swift.Void
    
    typealias PrevieImage = (_ image: UIImage) -> Swift.Void
    
    typealias FullImage = PrevieImage
        
    func getSmalImage(path: PathForItem, compliteImage: @escaping RemoteImage)
    
    func cancelImgeRequest(path: PathForItem)
    
}

protocol AsynImage {
    func getImage(patch: PathForItem, compliteImage:@escaping RemoteImage) -> URL?
}

class FilesDataSource: NSObject, PhotoDataSource, AsynImage {
    
    private let localManager = LocalMediaStorage.default
    
    private let getImageServise = ImageDownloder()
    
    private lazy var assetCache: PHCachingImageManager? = {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return nil
        }
        let cachingManager = PHCachingImageManager()
        cachingManager.allowsCachingHighQualityImages = false
        return cachingManager
    }()
    
    // MARK: PhotoDataSource

    func getSmalImage(path patch: PathForItem, compliteImage: @escaping RemoteImage) {
        
        switch patch {
        case let .localMediaContent(local):
            localManager.getPreviewImage(asset: local.asset, image: compliteImage)
            
        case let .remoteUrl(url):
            getImageServise.getImage(patch: url, compliteImage: compliteImage)
        }
    }
    
    func cancelImgeRequest(path: PathForItem) {
        switch path {
        case let .localMediaContent(local):
         localManager.cancelRequest(asset: local.asset)
            
        case let .remoteUrl(url):
            guard let u = url else {
                return
            }
            getImageServise.cancelRequest(path: u)
            break
        }
    }
    
    func cancelRequest(url: URL) {
        getImageServise.cancelRequest(path: url)
    }
    
    // MARK: AsynImage
    
    @discardableResult
    func getImage(patch: PathForItem, compliteImage: @escaping RemoteImage) -> URL? {
        switch patch {
        case let .localMediaContent(local):
            localManager.getPreviewImage(asset: local.asset, image: compliteImage)
            return nil
        case let .remoteUrl(url):
            getImageServise.getImage(patch: url, compliteImage: compliteImage)
            return url
        }
    }
    
    @discardableResult
    func getImage(for item: Item, isOriginal: Bool, compliteImage: @escaping RemoteImage) -> URL? {
        if isOriginal {
            switch item.patchToPreview {
            case let .localMediaContent(local):
                localManager.getPreviewMaxImage(asset: local.asset, image: compliteImage)
                
            case let .remoteUrl(url):
                if let largeUrl = item.metaData?.largeUrl {
                    getImageServise.getImage(patch: largeUrl, compliteImage: compliteImage)
                    return largeUrl
                } else {
                    getImageServise.getImage(patch: url, compliteImage: compliteImage)
                    return url
                }
            }
        } else {
            return getImage(patch: item.patchToPreview, compliteImage: compliteImage)
        }
        
        return nil
    }
    
    private let targetSize = CGSize(width: 300, height: 300)
    
    private lazy var defaultImageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        return options
    }()
    
    private lazy var defaultVideoRequestOptions: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        return options
    }()
    
}

extension FilesDataSource {
    
    //Mark: - Sync Image
    
    func stopCahcingAllImages() {
        assetCache?.stopCachingImagesForAllAssets()
    }
    
    func startCahcingImages(for assets: [PHAsset]) {
        assetCache?.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: defaultImageRequestOptions)
    }
    
    func stopCahcingImages(for assets: [PHAsset]) {
        assetCache?.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: defaultImageRequestOptions)
    }
    
    func getAssetThumbnail(asset: PHAsset, indexPath: IndexPath, completion: @escaping (_ image: UIImage?, _ indexPath: IndexPath) -> Void) {
        assetCache?.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: defaultImageRequestOptions, resultHandler: { image, _ in
            completion(image, indexPath)
        })
    }
}


extension FilesDataSource {
    func requestInfo(for asset: PHAsset, completion: @escaping (_ size: UInt64, _ url: URL?, _ isICloud: Bool) -> Void) {
        switch asset.mediaType {
        case .image:
            requestImageInfo(for: asset, completion: completion)
        case .video:
            requestVideoInfo(for: asset, completion: completion)
        default:
            completion(0, nil, false)
        }
    }
    
    private func requestImageInfo(for asset: PHAsset, completion: @escaping (_ size: UInt64, _ url: URL?, _ isICloud: Bool) -> Void) {
        assetCache?.requestImageData(for: asset, options: defaultImageRequestOptions, resultHandler: { (data, utType, orientation, info) in
            guard let isICloud = info?[PHImageResultIsInCloudKey] as? Bool, !isICloud,
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded,
                let data = data,
                let url = info?["PHImageFileURLKey"] as? URL
            else {
                completion(0, nil, true)
                return
            }
            
            completion(UInt64(data.count), url, false)
        })
    }
    
    private func requestVideoInfo(for asset: PHAsset, completion: @escaping (_ size: UInt64, _ url: URL?, _ isICloud: Bool) -> Void) {
        assetCache?.requestAVAsset(forVideo: asset, options: defaultVideoRequestOptions, resultHandler: { (avAsset, avAudioMix, info) in
            guard let isICloud = info?[PHImageResultIsInCloudKey] as? Bool, !isICloud,
                let urlToFile = (avAsset as? AVURLAsset)?.url
            else {
                completion(0, nil, true)
                return
            }
            
            var size = UInt64(0)
            do {
                size = try (FileManager.default.attributesOfItem(atPath: urlToFile.path)[.size] as! NSNumber).uint64Value
            } catch  {
                return completion(0, nil, true)
            }

            completion(size, urlToFile, false)
        })
    }
}


