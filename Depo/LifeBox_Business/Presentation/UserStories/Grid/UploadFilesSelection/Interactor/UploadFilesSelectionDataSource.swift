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
        
        if let cell = cell as? CollectionViewCellForPhoto  {
            cell.cloudStatusImage.isHidden = true
        }
    }
    
    func appendNewLocalItems(newItems: [BaseDataSourceItem]) {
        ///tableDataMArray for upload page uses only first row
        guard let alreadyStoredLocalItems = tableDataMArray.first else {
            tableDataMArray.append(newItems)
            reloadData()
            return
        }
        
        tableDataMArray = [alreadyStoredLocalItems + newItems]
        
        let prevItemsCount = alreadyStoredLocalItems.count
        let newItemsCount = newItems.count
        let totalItemsCount = prevItemsCount + newItemsCount
        
        let indexPaths = (prevItemsCount..<totalItemsCount).map { IndexPath(item: $0, section: 0) }
        insertItems(indexPaths: indexPaths)
    }
    
    func insertItems(indexPaths: [IndexPath]) {
        DispatchQueue.toMain { [weak self] in
            guard let self = self, let collectionView = self.collectionView else {
                return
            }
            
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellForPhoto,
            let unwrapedObject = itemForIndexPath(indexPath: indexPath)
        else {
            return
        }
        
        onSelectObjectWithQuickSelect(object: unwrapedObject)
        cell.setSelection(isSelectionActive: true, isSelected: true)
        updateSelectionCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellForPhoto,
            let unwrapedObject = itemForIndexPath(indexPath: indexPath)
        else {
            return
        }
     
        onDeselectObject(object: unwrapedObject)
        cell.setSelection(isSelectionActive: true, isSelected: false)
        updateSelectionCount()
    }
}
