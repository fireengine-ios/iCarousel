//
//  AlbumsDataSourceForCollectionView.swift
//  Depo
//
//  Created by 12345 on 20.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class AlbumsDataSourceForCollectionView: ArrayDataSourceForCollectionView {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    override func didUnhideAlbums(_ albums: [AlbumItem]) {
        delegate?.needReloadData()
    }
    
    override func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        delegate?.needReloadData()
    }
}
