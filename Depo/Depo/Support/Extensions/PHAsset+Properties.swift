//
//  PHAsset+Properties.swift
//  Images
//
//  Created by Bondar Yaroslav on 13/02/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import Photos

extension PHAsset {
    
    var resource: PHAssetResource? {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return nil
        }
        return PHAssetResource.assetResources(for: self).first
    }
    
    var originalFilename: String? {
        if #available(iOS 9.0, *) {
            return resource?.originalFilename
        } else {
            return value(forKey: "filename") as? String
        }
    }
    
    /// MAYBE WILL BE NEEDed
//    var uniformTypeIdentifier: String? {
//        if #available(iOS 9.0, *) {
//            return resource?.uniformTypeIdentifier
//        } else {
//            return value(forKey: "uniformTypeIdentifier") as? String
//        }
//    }
}
