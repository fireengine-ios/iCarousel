//
//  PHAsset+FetchAll.swift
//  Depo
//
//  Created by Konstantin Studilin on 06.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Photos

extension PHAsset {
    
    static func fetchAllAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        return PHAsset.fetchAssets(with: options)
    }
    
    static func getAllAssets() -> [PHAsset] {
        var assets = [PHAsset]()
        
        fetchAllAssets().enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        return assets
    }
}
