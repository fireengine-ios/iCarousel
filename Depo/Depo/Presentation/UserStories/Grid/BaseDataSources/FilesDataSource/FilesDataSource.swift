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
    
    typealias Itemslist = (_ items: [Item]) -> Void
    
    typealias PrevieImage = (_ image: UIImage) -> Void
    
    typealias FullImage = PrevieImage
        
    func getSmalImage(path: PathForItem, completeImage: @escaping RemoteImage)
    
    func cancelImgeRequest(path: PathForItem)
    
}

protocol AsynImage {
    func getImage(patch: PathForItem, completeImage:@escaping RemoteImage) -> URL?
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

    func getSmalImage(path patch: PathForItem, completeImage: @escaping RemoteImage) {
        
        switch patch {
        case let .localMediaContent(local):
            localManager.getPreviewImage(asset: local.asset, image: completeImage)
            
        case let .remoteUrl(url):
            getImageServise.getImage(patch: url, completeImage: completeImage)
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
    func getImage(patch: PathForItem, completeImage: @escaping RemoteImage) -> URL? {
        switch patch {
        case let .localMediaContent(local):
            localManager.getPreviewImage(asset: local.asset, image: completeImage)
            return nil
        case let .remoteUrl(url):
            getImageServise.getImage(patch: url, completeImage: completeImage)
            return url
        }
    }
    
    @discardableResult
    func getImage(for item: Item, isOriginal: Bool, completeImage: @escaping RemoteImage) -> URL? {
        if isOriginal {
            switch item.patchToPreview {
            case let .localMediaContent(local):
                localManager.getPreviewMaxImage(asset: local.asset, image: completeImage)
                
            case let .remoteUrl(url):
                if let largeUrl = item.metaData?.largeUrl {
                    getImageServise.getImage(patch: largeUrl, completeImage: completeImage)
                    return largeUrl
                } else {
                    getImageServise.getImage(patch: url, completeImage: completeImage)
                    return url
                }
            }
        } else {
            return getImage(patch: item.patchToPreview, completeImage: completeImage)
        }
        
        return nil
    }
    
    private let targetSize = CGSize(width: 300, height: 300)
    
    private lazy var defaultImageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
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
