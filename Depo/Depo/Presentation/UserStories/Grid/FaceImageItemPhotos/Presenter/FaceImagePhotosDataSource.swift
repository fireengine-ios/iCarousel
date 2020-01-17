//
//  FaceImagePhotosDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 12/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosDataSource: BaseDataSourceForCollectionView {
    
    var album: AlbumItem?
    
    override func didHideAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }

    override func didUnhideAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }
    
    override func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }
    
    override func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }
}
