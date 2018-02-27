//
//  AssetsСache.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

class AssetsСache {
    let dispatchQueue = DispatchQueue(label: "com.lifebox.assetCache")
    
    
    private var storage: [String: PHAsset] = [:]
    
    func assets(before oldest: Date) -> [PHAsset] {
        var assets = [PHAsset]()
        dispatchQueue.sync {
            assets = storage.values.filter({ (asset) -> Bool in
                guard let creationDate = asset.creationDate else {
                    return false
                }
                
                return creationDate > oldest
            })
        }
        return assets
    }
    
    func append(asset:PHAsset) {
        dispatchQueue.sync {
            storage[asset.localIdentifier] = asset
        }
    }
    
    func append(list:[PHAsset]) {
        dispatchQueue.sync {
            list.forEach {
                storage[$0.localIdentifier] = $0
            }
        }
    }
    
    func remove(identifier: String) {
        dispatchQueue.sync {
            _ = storage.removeValue(forKey: identifier)
        }
    }
    
    func assetBy(identifier: String) -> PHAsset? {
        var assets: PHAsset?
        dispatchQueue.sync {
            assets = storage[identifier]
        }
        return assets
    }
    
    func dropAll() {
        dispatchQueue.sync {
            storage.removeAll()
        }
    }
}
