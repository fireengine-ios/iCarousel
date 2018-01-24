//
//  ArrayDataSourceForCollectionView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 12.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ArrayDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    var tableDataMArray = [[BaseDataSourceItem]]()
    
    func configurateWithArray(array: [[BaseDataSourceItem]]){
        tableDataMArray.removeAll()
        tableDataMArray.append(contentsOf: array)
        collectionView?.reloadData()
//        allItems.append(array.first! as [WrapData])
    }
    
    override internal func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        let array = tableDataMArray[indexPath.section]
        return array[indexPath.row]
    }
    
    override func getAllObjects() -> [[BaseDataSourceItem]]{
        return tableDataMArray
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
        var resultArray = [BaseDataSourceItem]()
        for array in tableDataMArray{
            for object in array{
                if (selectedItemsArray.contains(object.uuid)){
                    resultArray.append(object)
                }
            }
        }
        return resultArray
    }
    
    override func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func albumsDeleted(albums: [AlbumItem]){
        if let unwrapedFilters = originalFilters,
            canShowAlbumsFilters(filters: unwrapedFilters) {
            let uuids = albums.map({ $0.uuid })
            var arrayOfIndexes = [IndexPath]()
            var section = 0
            var newArray = [[BaseDataSourceItem]]()
            for array in tableDataMArray{
                var row = 0
                var newSectionArray = [BaseDataSourceItem]()
                for album in array{
                    if uuids.contains(album.uuid){
                        let path = IndexPath(row: row, section: section)
                        arrayOfIndexes.append(path)
                    }else{
                        newSectionArray.append(album)
                    }
                    row = row + 1
                }
                section = section + 1
                newArray.append(newSectionArray)
            }
            
            
            if arrayOfIndexes.count > 0 {
                tableDataMArray = newArray
                collectionView?.performBatchUpdates({ [weak self] in
                    if let `self` = self{
                        self.collectionView?.deleteItems(at: arrayOfIndexes)
                    }
                }, completion: nil)
            }
        }
        
    }
    
}
