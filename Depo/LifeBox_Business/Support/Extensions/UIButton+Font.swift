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
    func centerVertically(padding: CGFloat = 6.0) {
        guard let imageSize = imageView?.image?.size, let label = titleLabel, let labelText = label.text else {
            return
        }
        
        self.titleEdgeInsets = UIEdgeInsets(top: padding,
                                            left: -imageSize.width,
                                            bottom: -(imageSize.height),
                                            right: 0.0)
        
        let labelString = NSString(string: labelText)
        let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: label.font])
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + padding),
                                            left: 0.0,
                                            bottom: 0.0,
                                            right: -titleSize.width)
    }
    
}
