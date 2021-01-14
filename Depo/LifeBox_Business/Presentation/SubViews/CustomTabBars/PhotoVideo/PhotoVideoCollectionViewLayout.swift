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
    
    let columns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
    
    private let padding: CGFloat = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        let viewWidth = UIScreen.main.bounds.width
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
