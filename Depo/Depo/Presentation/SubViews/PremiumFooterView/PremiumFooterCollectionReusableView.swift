//
//  PremiumFooterCollectionReusableView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PremiumFooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet private weak var premiumView: PremiumView!
    
    
    func configure(price: String?, type: FaceImageType) {
        let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
        premiumView.configure(with: String(format: TextConstants.faceImageFooterViewMessage, type.footerDescription),
                              price: price ?? TextConstants.free,
                              types: PremiumListType.allTypes,
                              isHiddenTitleImageView: true,
                              titleEdgeInsets: titleEdgeInsets,
                              isNeedScroll: false)
        
    }
    
    func addSelectedAmination() {
        premiumView.addSelectedAmination()
    }
}
