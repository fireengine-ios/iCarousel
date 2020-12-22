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
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return 0
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    var videosCount: Int {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return 0
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    var allAssets: [PHAsset] {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return []
        }
        
        let result = PHAsset.fetchAssets(in: self, options: nil)
        var assets = [PHAsset]()
        result.enumerateObjects { asset, _ , _ in
            assets.append(asset)
        }
        return assets
    }
    
    static var smartAlbums: [PHAssetCollection] {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return []
        }
        
        var albums = [PHAssetCollection]()
        let fetchRequest = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        fetchRequest.enumerateObjects { collection, _ , _  in
            albums.append(collection)
        }
        return albums
    }
    
    static func getAssets(for localIdentifiers: [String]) -> [PHAssetCollection] {
        var assets = [PHAssetCollection]()
        let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: localIdentifiers, options: nil)
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}
