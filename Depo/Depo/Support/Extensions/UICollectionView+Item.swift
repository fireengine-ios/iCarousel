//
//  UICollectionView+Item.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UICollectionView {
    @discardableResult
    func saveAndGetItemSize(for columnsNumber: Int) -> CGSize {
        
        let viewWidth = UIScreen.main.bounds.width

        let columns = CGFloat(columnsNumber)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.headerReferenceSize = CGSize(width: 0, height: 50)
        }
        return itemSize
    }
}
