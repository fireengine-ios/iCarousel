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
        for (section, array) in tableDataMArray.enumerated() {
            for (row, item) in array.enumerated() {
                if item.uuid == itemUUID {
                    return IndexPath(row: row, section: section)
                }
            }
        }

        return nil
    }
    
    override func updateFavoritesCellStatus(items: [Item], isFavorites: Bool) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let changedItemsIndexPaths = items.compactMap { self.getIndexPathForObject(itemUUID: $0.uuid) }
            
            if !changedItemsIndexPaths.isEmpty {
                let uuids = items.map { $0.uuid }
                
                for array in self.tableDataMArray {
                    for dataSourceItem in array {
                        if uuids.contains(dataSourceItem.uuid), let wrappedItem = dataSourceItem as? Item {
                            wrappedItem.favorites = isFavorites
                        }
                    }
                }
                
                DispatchQueue.toMain { [weak self] in
                    self?.collectionView?.performBatchUpdates({
                        self?.collectionView?.reloadItems(at: changedItemsIndexPaths)
                    }, completion: nil)
                }
            }
        }
    }
    
    override func newStoryCreated() {
        delegate?.needReloadData()
    }
    
}
