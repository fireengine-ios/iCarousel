//
//  UIBarButtonItem+Extensions.swift
//  Depo_LifeTech
//
//  Created by Maksim Rahleev on 6/8/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {

    convenience init(title: String,
                     font: UIFont? = nil,
                     tintColor: UIColor = ColorConstants.whiteColor,
                     accessibilityLabel: String? = nil,
                     style: UIBarButtonItemStyle = .plain,
                     target: Any?,
                     selector: Selector?) {

        self.init(title: title, style: style, target: target, action: selector)
        self.tintColor = tintColor
        self.accessibilityLabel = accessibilityLabel

        if let font = font {
            self.setTitleTextAttributes([.font : font], for: .normal)
        }
    }
}
