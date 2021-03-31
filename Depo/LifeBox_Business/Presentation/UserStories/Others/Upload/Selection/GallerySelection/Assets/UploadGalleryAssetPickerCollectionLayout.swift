//
//  UploadGalleryAssetPickerCollectionLayout.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit


final class UploadGalleryAssetPickerCollectionLayout: UICollectionViewFlowLayout {
    let columns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
    
    private let padding = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
    
    
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
        headerReferenceSize = CGSize(width: 0, height: 0)
    }
}
