//
//  AssetManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import Photos

struct LocalAlbumInfo {
    let identifier: String
    let name: String
    let numberOfItems: Int
}


final class AssetProvider {
    static let shared = AssetProvider()
    
    private let dispatchQueue = DispatchQueue(label: "AssetManager")
    
    
    private init() { }
    
    
    func getAlbumsWithItems(completion: @escaping ValueHandler<[LocalAlbumInfo]>) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        guard authStatus.isAccessible else {
            debugLog("Authorization status is \(authStatus)")
            return completion([])
        }
        
        dispatchQueue.async {
            let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            
            var albums = [LocalAlbumInfo]()
            [albumsResult, smartAlbumsResult].forEach {
                $0.enumerateObjects { album, _, _ in
                    let numberOfItems = album.photosCount + album.videosCount
                    
                    if numberOfItems > 0 {
                        let albumInfo = LocalAlbumInfo(identifier: album.localIdentifier,
                                                       name: album.localizedTitle ?? "",
                                                       numberOfItems: numberOfItems)
                        albums.append(albumInfo)
                    }
                }
            }
            completion(albums)
        }
    }
    
    
    func getAllAssets(for albumId: String) -> [PHAsset] {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        guard authStatus.isAccessible else {
            debugLog("Authorization status is \(authStatus)")
            return []
        }
        
        guard
            let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumId], options: nil).firstObject
        else {
            return []
        }
        
        let assetsResult = PHAsset.fetchAssets(in: album, options: nil)
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    
}
