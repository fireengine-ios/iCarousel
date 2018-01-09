//
//  PhotoSelectiondDataSource.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/16/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoSelectionDataSource: ArrayDataSourceForCollectionView {
    
    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?){
        super.setupCollectionView(collectionView: collectionView, filters: [.fileType(.audio)])
        let nib = UINib(nibName: CollectionViewCellsIdsConstant.cellForStoryImage, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForStoryImage)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForStoryImage, for: indexPath)
    }
    
    override func configurateWithArray(array: [[BaseDataSourceItem]]){
        tableDataMArray.append(contentsOf: array)
        collectionView.reloadData()
    }
    
    override func dropData() {
        tableDataMArray.removeAll()
        super.dropData()
    }
}
