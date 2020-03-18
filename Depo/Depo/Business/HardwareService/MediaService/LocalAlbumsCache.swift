//
//  LocalAlbumsCache.swift
//  Depo
//
//  Created by Konstantin Studilin on 18/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Photos


final class LocalAlbumsCache {
    
    static let shared = LocalAlbumsCache()
    
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.localAlbumsCacheQueue)
    private var storage = [String: [String]]() // [assetId: [albumId]]
    
    
    private init() {}
    
    func append(albumId: String, with assetIds: [String]) {
        queue.async(flags: .barrier) {
            assetIds.forEach {
                if self.storage[$0] == nil {
                    self.storage[$0] = [albumId]
                } else {
                    self.storage[$0]?.append(albumId)
                }
            }
        }
    }
    
    func albumIds(assetId: String) -> [String] {
        var result = [String]()
        queue.sync {
            result = self.storage[assetId] ?? []
        }
        return result
    }
}
