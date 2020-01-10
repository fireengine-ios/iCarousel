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
    
    override func getSelectedItems() -> [BaseDataSourceItem] {
        if isSelectionStateActive {
            return super.getSelectedItems()
        } else if let album = album {
            return [album]
        }
        return []
    }
    
    override func didHideAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }

    override func albumsDeleted(albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }
    
    override func didUnhideAlbums(_ albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }
}
