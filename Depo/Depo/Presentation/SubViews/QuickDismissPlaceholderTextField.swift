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
    
    override func becomeFirstResponder() -> Bool {
        changePlaceholderColor()
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        changePlaceholderColor()
        
        return super.resignFirstResponder()
    }
    
    private func changePlaceholderColor() {
        guard let placeholder = attributedPlaceholder?.string else {
                return
        }
        
        ///inversed because called before super
        let color = isFirstResponder ? placeholderColor : UIColor.clear
        let attributes: [NSAttributedStringKey : Any] = [ .foregroundColor : color ]
        let attributedPlaceholder = NSMutableAttributedString(string: placeholder,
                                                    attributes: attributes)

        self.attributedPlaceholder = attributedPlaceholder
    }
}
