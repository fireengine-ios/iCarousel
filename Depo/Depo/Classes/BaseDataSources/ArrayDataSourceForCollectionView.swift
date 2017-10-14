//
//  ArrayDataSourceForCollectionView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 12.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ArrayDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    var tableDataMArray = [[WrapData]]()
    
    func configurateWithArray(array: [[WrapData]]){
        tableDataMArray.removeAll()
        tableDataMArray.append(contentsOf: array)
        collectionView.reloadData()
    }
    
    override internal func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        let array = tableDataMArray[indexPath.section]
        return array[indexPath.row]
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableDataMArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let array = tableDataMArray[section]
        return array.count
    }
    
    override func isHeaderSelected(section: Int) -> Bool{
        let array = tableDataMArray[section]
        let result: [String] = array.flatMap { $0.uuid}
        let subSet = Set<String>(result)
        
        return subSet.isSubset(of: selectedItemsArray)
    }
    
    override func getSelectedItems() -> [BaseDataSourceItem] {
        var resultArray = [WrapData]()
        for array in tableDataMArray{
            for object in array{
                if (selectedItemsArray.contains(object.uuid)){
                    resultArray.append(object)
                }
            }
        }
        return resultArray
    }
    
}
