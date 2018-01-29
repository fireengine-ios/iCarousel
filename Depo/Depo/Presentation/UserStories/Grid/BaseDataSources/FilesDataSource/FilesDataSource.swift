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
    
    associatedtype Item
    
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
  
    typealias Item = WrapData
    
    private let localManager = LocalMediaStorage.default
    
//    private let remoteManager = SearchService()
    
    private let getImageServise = ImageDownloder()
    
    private var assetCache: PHCachingImageManager? {
        var cachingManager: PHCachingImageManager?
        if LocalMediaStorage.default.photoLibraryIsAvailible() {
            cachingManager = PHCachingImageManager()
        }
        return cachingManager
    }
    
    
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
            guard let u = url else{
                return
            }
            getImageServise.cancelRequest(path: u)
            break
        }
    }
    
    func cancelRequest(url: URL) {
        getImageServise.cancelRequest(path: url)
    }
    
    //MARK: AsynImage
    
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
    
    //Mark: - Sync Image
    
    func getAssetThumbnail(asset: PHAsset, indexPath: IndexPath, completion: @escaping (_ image: UIImage?, _ indexPath: IndexPath)->Void) -> PHImageRequestID {
        let manager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.version = .current
        options.deliveryMode = .opportunistic
        
        let targetSize = CGSize(width: 300, height: 300)

        if let cachingManager = assetCache {
            cachingManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: options)
        }
        
        return manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
//            if let isDegaraded = (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue, !isDegaraded {
                completion(result, indexPath)
//            }
        })
    }
    
    func cancelRequestByID(requestID: PHImageRequestID){
        let manager = PHImageManager.default()
        manager.cancelImageRequest(requestID)
    }
}
