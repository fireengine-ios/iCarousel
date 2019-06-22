//
//  MigrationPolicy_1_3.swift
//  Depo
//
//  Created by Konstantin Studilin on 03/06/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


class MediaItemMigrationPolicy_1_3: NSEntityMigrationPolicy {
    @objc func uuidWith(_ trimmedLocalFileID:String) -> String {
        return trimmedLocalFileID.appending("~\(UUID().uuidString)")
    }
}

class MediaItemMetaDataMigrationPolicy_1_3: NSEntityMigrationPolicy {
    @objc func durationWith(_ duration: NSNumber, assetId:String?) -> NSNumber {
        guard duration.doubleValue == -1.0 else {
            return duration
        }
        
        if LocalMediaStorage.default.photoLibraryIsAvailible(),
            let assetId = assetId,
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject
        {
            return NSNumber(value: asset.duration)
        }
        
        return NSNumber(value: 0.0)
    }
}
