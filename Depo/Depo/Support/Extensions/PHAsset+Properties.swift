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
        return resources.first(where: { $0.type.isContained(in: [.photo, .video]) })
    }
    
    var originalFilename: String? {
        let name = resource?.originalFilename
//        print("originalName = \(name ?? "")")
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
