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
    
    static func getAllAssets(with localIdentifiers: [String]) -> [PHAsset] {
        let options = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: options)
        
        var assets = [PHAsset]()
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
}
