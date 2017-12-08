//
//  UploadFilesSelectionDataSource.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 12/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionDataSource: ArrayDataSourceForCollectionView {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        guard let _ = itemForIndexPath(indexPath: indexPath),
            let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        if let cell = cell_ as? CollectionViewCellForPhoto {
            cell.isShowSyncStatus = false
        }
    }
    
}

