//
//  QuickDismissPlaceholderTextField.swift
//  Depo
//
//  Created by Raman Harhun on 4/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class QuickDismissPlaceholderTextField: UnderlineTextField {
    
    var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            changePlaceholderColor()
        }
    }
    
    var quickDismissPlaceholder: String = "" {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: quickDismissPlaceholder)
            changePlaceholderColor()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        
        changePlaceholderColor()
        
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        changePlaceholderColor()
        
        return result
    }
    
    private func changePlaceholderColor() {
        guard let placeholder = attributedPlaceholder?.string else {
                return
        }
        
        let color = isFirstResponder ? UIColor.clear : placeholderColor
        let attributes: [NSAttributedStringKey : Any] = [ .foregroundColor : color ]
        let attributedPlaceholder = NSMutableAttributedString(string: placeholder,
                                                    attributes: attributes)

        self.attributedPlaceholder = attributedPlaceholder
    }
}
