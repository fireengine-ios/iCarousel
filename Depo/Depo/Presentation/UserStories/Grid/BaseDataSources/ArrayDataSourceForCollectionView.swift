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
    
    override func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func albumsDeleted(albums: [AlbumItem]) {
        if let unwrapedFilters = originalFilters,
            canShowAlbumsFilters(filters: unwrapedFilters) {
            let uuids = albums.map({ $0.uuid })
            var arrayOfIndexes = [IndexPath]()
            var newArray = [[BaseDataSourceItem]]()
            for (section, array) in tableDataMArray.enumerated() {
                var newSectionArray = [BaseDataSourceItem]()
                for (row, album) in array.enumerated() {
                    if uuids.contains(album.uuid) {
                        let path = IndexPath(row: row, section: section)
                        arrayOfIndexes.append(path)
                    } else {
                        newSectionArray.append(album)
                    }
                }
                newArray.append(newSectionArray)
            }
        
            if !arrayOfIndexes.isEmpty {
                collectionView?.performBatchUpdates({ [weak self] in
                    self?.tableDataMArray = newArray
                    self?.collectionView?.deleteItems(at: arrayOfIndexes)
                }, completion: { [weak self] finished in
                    self?.delegate?.didDelete(items: albums)
                })
            }
        }
        
    }
    
    override func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        guard let unwrapedFilters = originalFilters,
            canShowAlbumsFilters(filters: unwrapedFilters) else {
                return
        }
        for (section, array) in tableDataMArray.enumerated() {
            for (row, album) in array.enumerated() {
                if album.uuid == item.uuid {
                    let indexPath = IndexPath(row: row, section: section)
                    collectionView?.performBatchUpdates({
                        collectionView?.reloadItems(at: [indexPath])
                    }, completion: nil)
                    return
                }
            }
        }
    }
    
}
