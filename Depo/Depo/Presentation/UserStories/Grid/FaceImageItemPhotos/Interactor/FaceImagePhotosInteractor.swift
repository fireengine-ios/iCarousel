//
//  FaceImagePhotosInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosInteractor: BaseFilesGreedInteractor {
    
    let service = AlbumDetailService(requestSize: 1)
    
    var album: AlbumItem?
    
    override func viewIsReady() {
        if let output = output as? FaceImagePhotosInteractorOutput,
            let album = album {
            output.didCountImage(album.imageCount ?? 0)
        }
    }
    
    func updateCoverPhotoIfNeeded() {
        if let album = album {
            update(album: album)
        }
    }
    
    fileprivate func update(album: AlbumItem) {
        service.albumCoverPhoto(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { coverPhoto in
            if album.preview?.uuid != coverPhoto.uuid {
                album.preview = coverPhoto
                ItemOperationManager.default.updatedAlbumCoverPhoto(item: album)
            }
        }, fail: {
            // TODO: NEED TO CHANGE SERVICE FOR ERROR HANDLER
        })
    }
}
