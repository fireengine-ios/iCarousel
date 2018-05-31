//
//  PhotoSelectiondDataSource.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/16/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoSelectionDataSource: ArrayDataSourceForCollectionView {
    
    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?) {
        super.setupCollectionView(collectionView: collectionView, filters: filters)
        
        let nib = UINib(nibName: CollectionViewCellsIdsConstant.cellForStoryImage, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForStoryImage)
        
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.collectionViewHeaderWithText, bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewHeaderWithText)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForStoryImage, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section == 0) {
            return CGSize(width: collectionView.bounds.size.width, height: 53.0)
        } else {
            let height = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
            return CGSize(width: collectionView.bounds.size.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewHeaderWithText, for: indexPath) as! CollectionViewHeaderWithText
            headerView.titleLabel.isHidden = indexPath.section != 0
            return headerView
        case UICollectionElementKindSectionFooter:
            if indexPath.section == allItems.count - 1, !isPaginationDidEnd,
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter, for: indexPath) as? CollectionViewSpinnerFooter
            {
                footerView.startSpinner()
                return footerView
                
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter, for: indexPath)
            }
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    override func configurateWithArray(array: [[BaseDataSourceItem]]) {
        tableDataMArray.append(contentsOf: array)
        collectionView?.reloadData()
    }
    
    override func setupOneSectionMediaItemsArray(items: [WrapData]) {
        tableDataMArray.append(items)
    }
    
    override func allObjectIsEmpty() -> Bool {
        for array in tableDataMArray {
            if !array.isEmpty {
                return false
            }
        }
        return true
    }
    
    override func dropData() {
        tableDataMArray.removeAll()
        super.dropData()
    }
    
    override func updateSelectionCount() {
        super.updateSelectionCount()
    }
}
