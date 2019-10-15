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
        /// firstSubview doesn't work because of UITextFieldClearButton
        /// https://stackoverflow.com/a/54533194
        
        if let cancelButton = value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
}
