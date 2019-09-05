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
        if #available(iOS 13.0, *) {
            //TODO: check again on GM or release ios 13 version
            /* ios 13.1 beta returns:
             - Adjustments.plist as originalFilename for the photos with enabled filter and slo-mo
             - *.MOV for the live photos with Most Compatible format
            */
            return value(forKey: "filename") as? String
        } else {
            return resource?.originalFilename
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
