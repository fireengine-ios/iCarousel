//
//  AssetsCache.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

class AssetsCache {
    let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.assetCache)
    
    
    private var storage: [String: PHAsset] = [:]
    
    private var sortedStorage: [PHAsset] {
        return storage.values.sorted{
            guard let creationDate1 = $0.creationDate,
                let creationDate2 = $1.creationDate else {
                    return false
            }
           return creationDate1 > creationDate2
            
        }
    }
    
    func assets(before oldest: Date, mediaType: PHAssetMediaType) -> [PHAsset] {
        var assets = [PHAsset]()
        dispatchQueue.sync {
            assets = sortedStorage.filter({ (asset) -> Bool in
                guard let creationDate = asset.creationDate, asset.mediaType == mediaType else {
                    return false
                }
                
                return creationDate > oldest
            })
        }
        return assets
    }

    func assets(beforeDate: Date, afterDate: Date, mediaType: PHAssetMediaType) -> [PHAsset]{
        return sortedStorage.filter{ (asset) -> Bool in
            guard let creationDate = asset.creationDate, asset.mediaType == mediaType else {
                return false
            }
            
            return (creationDate > beforeDate) && (creationDate < afterDate)
        }
    }
    
    func assets(afterDate: Date, mediaType: PHAssetMediaType) -> [PHAsset] {
        var assets = [PHAsset]()
        dispatchQueue.sync {
            assets = sortedStorage.filter({ (asset) -> Bool in
                guard let creationDate = asset.creationDate, asset.mediaType == mediaType else {
                    return false
                }
                
                return creationDate < afterDate
            })
        }
        return assets
    }
    
    func append(asset:PHAsset) {
        dispatchQueue.sync {
            storage[asset.localIdentifier] = asset
        }
    }
    
    func append(list: [PHAsset]) {
        dispatchQueue.sync {
            list.forEach {
                storage[$0.localIdentifier] = $0
            }
        }
    }
    
    func remove(list: [PHAsset]) {
        dispatchQueue.sync {
            list.forEach {
                storage.removeValue(forKey: $0.localIdentifier)
            }
        }
    }
    
    func remove(identifier: String) {
        dispatchQueue.sync {
            _ = storage.removeValue(forKey: identifier)
        }
    }
    
    func remove(identifiers: [String]) {
        dispatchQueue.sync {
            identifiers.forEach {
                storage.removeValue(forKey: $0)
            }
        }
    }
    
    func assetBy(identifier: String) -> PHAsset? {
        var result: PHAsset?
        dispatchQueue.sync {
            result = storage[identifier]
        }
        return result
    }
    
    func dropAll() {
        dispatchQueue.sync {
            storage.removeAll()
        }
    }
    
    func replaceAll(with list: [PHAsset]) {
        dispatchQueue.sync {
            storage.removeAll()
            list.forEach {
                storage[$0.localIdentifier] = $0
            }
        }
    }
}
