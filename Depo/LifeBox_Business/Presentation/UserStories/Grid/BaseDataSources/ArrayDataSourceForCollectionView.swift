//
//  ArrayDataSourceForCollectionView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 12.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ArrayDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var tableDataMArray = [[BaseDataSourceItem]]()
    
    func configurateWithArray(array: [[BaseDataSourceItem]]) {
        tableDataMArray.removeAll()
        tableDataMArray.append(contentsOf: array)
        collectionView?.reloadData()
//        allItems.append(array.first! as [WrapData])
    }
    
    override func dropData() {
        super.dropData()
        tableDataMArray.removeAll()
    }
    
    override internal func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        guard tableDataMArray.count > indexPath.section, tableDataMArray[indexPath.section].count > indexPath.row else {
            return nil
        }
        
        return tableDataMArray[safe: indexPath.section]?[safe: indexPath.row]
    }
    
    override func getAllObjects() -> [[BaseDataSourceItem]] {
        return tableDataMArray
    }
    
    override func setAllItems(items: [[BaseDataSourceItem]]) {
        tableDataMArray = items
    }
    
    override func setupOneSectionMediaItemsArray(items: [WrapData]) {
        tableDataMArray.removeAll()
        tableDataMArray.append(items)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableDataMArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let array = tableDataMArray[section]
        return array.count
    }
    
    override func isHeaderSelected(section: Int) -> Bool {
        let arrayOfObjectsInSction = tableDataMArray[section]
        let subSet = Set<BaseDataSourceItem>(arrayOfObjectsInSction)
        return subSet.isSubset(of: selectedItemsArray)
    }
    
    override func getSelectedItems() -> [BaseDataSourceItem] {
        if isSelectionStateActive {
            var resultArray = [BaseDataSourceItem]()
            for array in tableDataMArray {
                for object in array {
                    if (selectedItemsArray.contains(object)) {
                        resultArray.append(object)
                    }
                }
            }
            return resultArray
        }
        
        if let parent = delegate?.getParent() {
            return [parent]
        }
        return []
    }
    
    override func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}
