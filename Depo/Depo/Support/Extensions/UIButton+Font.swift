//
//  UIButton+Font.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 5/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIButton {
    // TODO: check for titleEdgeInsets and InsetsButton class
    func adjustsFontSizeToFitWidth() {
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.baselineAdjustment = .alignCenters
        titleLabel?.lineBreakMode = .byClipping
    }
}

//MARK: - VerticalLayout

extension UIButton {
    func centerVertically(padding: CGFloat = 6.0, topPadding: CGFloat = 0.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height - topPadding),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}
