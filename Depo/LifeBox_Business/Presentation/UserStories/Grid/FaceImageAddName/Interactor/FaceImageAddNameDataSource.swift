//
//  FaceImageAddNameDataSource.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class FaceImageAddNameDataSource: BaseDataSourceForCollectionView {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let file = itemForIndexPath(indexPath: indexPath)
        
        var cellReUseID = preferedCellReUseID
        if (cellReUseID == nil), let unwrapedFile = file {
            cellReUseID = unwrapedFile.getCellReUseID()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReUseID!,
                                                      for: indexPath)
        
        if !needShowCloudIcon {
            if let cell = cell as? CollectionViewCellForPhoto {
                cell.cloudStatusImage.isHidden = true
            }
        }
        
        return  cell
    }
}
