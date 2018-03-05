//
//  UICollectionView+Layout.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UICollectionView {
    func setLayout(itemSize: CGSize? = nil, lineSpacing: CGFloat? = nil, itemSpacing: CGFloat? = nil) {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            if let itemSize = itemSize {
                layout.itemSize = itemSize
            }
            if let lineSpacing = lineSpacing {
                layout.minimumLineSpacing = lineSpacing
            }
            if let itemSpacing = itemSpacing {
                layout.minimumInteritemSpacing = itemSpacing
            }
        }
    }
}
