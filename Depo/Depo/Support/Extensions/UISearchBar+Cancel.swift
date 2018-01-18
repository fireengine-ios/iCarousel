//
//  UISearchBar+Cancel.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UISearchBar {
    func enableCancelButton() {
        for view in subviews {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.isEnabled = true
                }
            }
        }
    }
}
