//
//  PHAssetCollection.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 27.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Photos

extension PHAssetCollection {
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
