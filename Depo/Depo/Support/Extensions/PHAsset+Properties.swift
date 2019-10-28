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
        let resources = PHAssetResource.assetResources(for: self)
        
        if let editedResource = resources.first(where: { $0.type.isContained(in: [.fullSizePhoto, .fullSizeVideo]) }) {
            return editedResource
        } else {
            return resources.first(where: { $0.type.isContained(in: [.photo, .video]) })
        }
    }
    
    var originalFilename: String? {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return nil
        }
        let resources = PHAssetResource.assetResources(for: self)
        /// original resource for original filename
        /// we show IMG_XXXX.HEIC, but will be upload edited jpg photo
        let originalResource = resources.first(where: { $0.type.isContained(in: [.photo, .video]) })
        let name = originalResource?.originalFilename
        return name
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
