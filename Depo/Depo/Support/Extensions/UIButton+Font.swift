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
