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
    
    func getImage(patch: PathForItem, compliteImage:@escaping RemoteImage)
}

class FilesDataSource: NSObject, PhotoDataSource, AsynImage {
  
    typealias Item = WrapData
    
    private let localManager = LocalMediaStorage.default
    
    private let remoteManager = SearchService()
    
    private let getImageServise = ImageDownloder()
    
    
    // MARK: check acces to local media library
    
    func checkAccessToMediaLibrary() -> Bool {
        return localManager.photoIsAvalible()
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
    
    
    //MARK: AsynImage
    
    func getImage(patch: PathForItem, compliteImage: @escaping RemoteImage) {
        switch patch {
        case let .localMediaContent(local):
            localManager.getPreviewImage(asset: local.asset, image: compliteImage)
        case let .remoteUrl(url):
            getImageServise.getImage(patch: url, compliteImage: compliteImage)
        }
    }
    
    func getImage(for item: Item, isOriginal: Bool, compliteImage: @escaping RemoteImage) {
        if isOriginal {
            switch item.patchToPreview {
            case let .localMediaContent(local):
                localManager.getPreviewMaxImage(asset: local.asset, image: compliteImage)
                
            case let .remoteUrl(url):
                if let largeUrl = item.metaData?.largeUrl {
                    getImageServise.getImage(patch: largeUrl, compliteImage: compliteImage)
                } else {
                    getImageServise.getImage(patch: url, compliteImage: compliteImage)
                }
            }
            
        } else {
            getImage(patch: item.patchToPreview, compliteImage: compliteImage)
        }
    }
}
