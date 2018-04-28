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
        tableDataMArray = newArray
        
        ItemOperationManager.default.deleteStories(items: items)
        delegate?.didDelete(items: items)
        
        updateCoverPhoto()
        collectionView?.reloadData()
    }
    
    override func newStoryCreated() {
        delegate?.needReloadData()
    }
    
}
