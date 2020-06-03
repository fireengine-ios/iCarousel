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
        
        cancelButton?.isEnabled = true
    }
    
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "searchField") as? UITextField
        }
    }
    
    var cancelButton: UIButton? {
        return value(forKey: "cancelButton") as? UIButton
    }
}
