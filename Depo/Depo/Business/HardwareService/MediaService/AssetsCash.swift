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
    
    private var storage: [String: PHAsset] = [:]
    
    func append(asset:PHAsset) {
        storage[asset.localIdentifier] = asset
    }
    
    func append(list:[PHAsset]) {
        list.forEach {
            storage[$0.localIdentifier] = $0
        }
    }
    
    func remove(identifier: String) {
        storage.removeValue(forKey: identifier)
    }
    
    func assetBy(identifier: String) -> PHAsset? {
       return storage[identifier]
    }
    
    func dropAll() {
        storage.removeAll()
    }
}
