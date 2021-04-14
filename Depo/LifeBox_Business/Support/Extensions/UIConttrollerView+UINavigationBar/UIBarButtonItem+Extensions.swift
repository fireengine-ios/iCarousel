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
            /// not working setTitleTextAttributes([.font : font], for: [.normal, .highlighted])
            setTitleTextAttributes([.font : font], for: .normal)
            setTitleTextAttributes([.font : font], for: .highlighted)
            setTitleTextAttributes([.font : font], for: .disabled)
            setTitleTextAttributes([.font : font], for: .selected)
        }
    }
    
    /// if you use the properties for the buttons there is a bug only on ios 11 with the replacement of buttons by clicking on them
    /// https://forums.developer.apple.com/thread/75521
    func fixEnabledState() {
        isEnabled = false
        isEnabled = true
    }
    
}
