//
//  PremiumFooterCollectionReusableView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PremiumFooterCollectionReusableViewDelegate: class {
    func onBecomePremiumTap()
}

final class PremiumFooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet private weak var premiumView: PremiumView!
    
    weak var delegate: PremiumFooterCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        premiumView.delegate = self
    }
    
    func configure(price: String?, description: String, type: FaceImageType, isSelectedAnimation: Bool? = false) {
        let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
        let descriptionMessage = String(format: TextConstants.faceImageFooterViewMessage, type.footerDescription)
        premiumView.configure(with: descriptionMessage,
                              price: price,
                              description: description,
                              types: PremiumListType.allTypes,
                              isHiddenTitleImageView: true,
                              titleEdgeInsets: titleEdgeInsets,
                              isNeedScroll: false,
                              isNeedPolicy: false)
        if isSelectedAnimation == true {
            addSelectedAmination()
        }
    }
    
    // MARK: Utility methods
    private func addSelectedAmination() {
        premiumView.addSelectedAmination()
    }
    
}

// MARK: PremiumViewDelegate
extension PremiumFooterCollectionReusableView: PremiumViewDelegate {
    
    func onBecomePremiumTap() {
        delegate?.onBecomePremiumTap()
    }
    
}
