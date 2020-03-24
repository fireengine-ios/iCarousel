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

    private let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
    
    @IBOutlet private weak var premiumView: PremiumView!
    
    weak var delegate: PremiumFooterCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        premiumView.delegate = self
    }
    
    func configure(price: String?, description: String, type: FaceImageType, isSelectedAnimation: Bool? = false, isTurkcell: Bool) {
        let title = String(format: TextConstants.faceImageFooterViewMessage, type.footerDescription)
        premiumView.configure(with: title,
                              price: price,
                              description: description,
                              types: PremiumListType.allTypes,
                              isHiddenTitleImageView: true,
                              titleEdgeInsets: titleEdgeInsets,
                              isNeedScroll: false,
                              isNeedPolicy: false,
                              isTurkcell: isTurkcell)
        if isSelectedAnimation == true {
            addSelectedAmination()
        }
    }
    
    func configureWithoutDetails(type: FaceImageType, isSelectedAnimation: Bool) {
        let title = String(format: TextConstants.faceImageFooterViewMessage, type.footerDescription)
        premiumView.configure(with: title, price: "",
                              description: "", types: [],
                              titleEdgeInsets: titleEdgeInsets,
                              isNeedPolicy: false, isTurkcell: false)
        if isSelectedAnimation {
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
    
    func showTermsOfUse() {
        //delegate func, used only in PremiumViewController
    }
    
    func openLink(with url: URL) {
        //delegate func, used only in PremiumViewController
    }
}
