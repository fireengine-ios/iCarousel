//
//  ContactSyncBaseCardView.swift
//  Depo
//
//  Created by Andrei Novikau on 6/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class ContactSyncBaseCardView: UIView {
    
    //MARK:- Override
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupShadow()
    }
    
    private func setupShadow() {
        layer.cornerRadius = NumericConstants.contactSyncSmallCardCornerRadius
        
        clipsToBounds = false

        layer.borderWidth = 1.5
        layer.borderColor = AppColor.contactsBorderColor.color.cgColor
        
        layer.shadowColor = AppColor.cellShadow.color.cgColor
        layer.shadowOpacity = NumericConstants.contactSyncSmallCardShadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = NumericConstants.contactSyncSmallCardShadowRadius
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: 0,
                                                     width: layer.frame.size.width,
                                                     height: layer.frame.size.height)).cgPath
    }
}
