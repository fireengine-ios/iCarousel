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
    func adjustsFontSizeToFitWidth(numberOfLines: Int = 1) {
        titleLabel?.numberOfLines = numberOfLines
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byClipping
    }
}
