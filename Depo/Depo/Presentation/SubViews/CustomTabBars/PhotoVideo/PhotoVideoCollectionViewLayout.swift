//
//  PhotoVideoCollectionViewLayout.swift
//  Depo
//
//  Created by Andrei Novikau on 4/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoCollectionViewLayoutDelegate: class {
    func targetContentOffset() -> CGPoint?
}

final class PhotoVideoCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var delegate: PhotoVideoCollectionViewLayoutDelegate?
    
    private(set) lazy var columnsNumber: Int = {
        let viewWidth = UIScreen.main.bounds.width
        let desiredItemWidth: CGFloat = 100
        let preferredCount = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
        return Int(max(floor(viewWidth / desiredItemWidth), CGFloat(preferredCount)))
    }()
    
    private let padding: CGFloat = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        let viewWidth = UIScreen.main.bounds.width
        let columns = CGFloat(columnsNumber)
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        itemSize = CGSize(width: itemWidth, height: itemWidth)

        minimumInteritemSpacing = padding
        minimumLineSpacing = padding
        headerReferenceSize = CGSize(width: 0, height: 50)
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        guard collectionView?.isDragging == false, let contentOffset = delegate?.targetContentOffset() else {
            return
        }
        
        collectionView?.setContentOffset(contentOffset, animated: false)
    }
}
