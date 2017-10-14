//
//  ColumnsCollectionLayout.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/20/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

// TODO: landscape layout

final class ColumnsCollectionLayout: UICollectionViewFlowLayout {
    
    @IBInspectable var numberOfColumns: Int = 2
    @IBInspectable var cellHeight: CGFloat = 100
    
//    public override func awakeFromNib() {
//        super.awakeFromNib()
//        setup()
//    }
//
//    private func setup() {
//        let size = width(for: numberOfColumns)
//        itemSize = CGSize(width: size, height: cellHeight)
//    }
//
//    private func width(for numberOfColumns: Int) -> CGFloat {
//        guard let collView = collectionView else { return 0 }
//        let emptySpace = sectionInset.left + sectionInset.right + minimumInteritemSpacing * CGFloat(numberOfColumns - 1)
//        return (collView.bounds.width - emptySpace) / CGFloat(numberOfColumns)
//    }
    
    override var itemSize: CGSize {
        get {
            guard let collectionView = collectionView else {
                return super.itemSize
            }
            let marginsAndInsets = sectionInset.left + sectionInset.right + minimumInteritemSpacing * CGFloat(numberOfColumns - 1)
            collectionView.setNeedsLayout()
            let itemWidth = ((collectionView.bounds.width - marginsAndInsets) / CGFloat(numberOfColumns)).rounded(.down)
            return CGSize(width: itemWidth, height: cellHeight)
        }
        set {
            super.itemSize = newValue
        }
    }
}
