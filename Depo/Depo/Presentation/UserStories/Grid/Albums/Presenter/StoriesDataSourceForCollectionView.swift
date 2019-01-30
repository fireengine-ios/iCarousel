//
//  StoriesDataSourceForCollectionView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 06.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesDataSourceForCollectionView: ArrayDataSourceForCollectionView {

    override func deleteItems(items: [Item]) {
        let removeIds = items.map { $0.uuid }
        var newArray = [[BaseDataSourceItem]]()
        for array in tableDataMArray {
            var sectionArray = [BaseDataSourceItem]()
            for arraysObject in array {
                if !removeIds.contains(arraysObject.uuid) {
                    sectionArray.append(arraysObject)
                }
            }
            newArray.append(sectionArray)
        }
        
        setAllItems(items: newArray)
        
        ItemOperationManager.default.deleteStories(items: items)
        delegate?.didDelete(items: items)
        
        updateCoverPhoto()
        collectionView?.reloadData()
    }
    
    override func getIndexPathForObject(itemUUID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        
        for (section, array) in tableDataMArray.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.uuid == itemUUID {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    override func updateFavoritesCellStatus(items: [Item], isFavorites: Bool) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            var arrayOfPath = [IndexPath]()
            
            for item in items {
                if let path = self.getIndexPathForObject(itemUUID: item.uuid) {
                    arrayOfPath.append(path)
                }
            }
            
            if arrayOfPath.count > 0 {
                let uuids = items.map { $0.uuid }
                for array in self.tableDataMArray {
                    for arraysObject in array {
                        if uuids.contains(arraysObject.uuid), let arraysItem = arraysObject as? Item {
                            arraysItem.favorites = isFavorites
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.performBatchUpdates({ [weak self] in
                            self?.collectionView?.reloadItems(at: arrayOfPath)
                        }, completion: nil)
                }
            }
        }
    }
    
    override func newStoryCreated() {
        delegate?.needReloadData()
    }
    
}
