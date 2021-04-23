//
//  QuickDismissPlaceholderTextField.swift
//  Depo
//
//  Created by Raman Harhun on 4/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class QuickDismissPlaceholderTextField: UnderlineTextField {
    
    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            layoutIfNeeded()
            let label = placeholderLabel
            label?.adjustsFontSizeToFitWidth()
        }
    }
    
    var placeholderColor: UIColor = ColorConstants.placeholderGrayColor.color {
        didSet {
            changePlaceholderColor()
        }
    }
        
    var quickDismissPlaceholder = "" {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: quickDismissPlaceholder)
            changePlaceholderColor()
        }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        changePlaceholderColor()
        return result
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        changePlaceholderColor()
        return result
    }
    
    private func changePlaceholderColor() {
        guard let placeholder = self.attributedPlaceholder?.string else {
            return
        }
        
        let color = isFirstResponder ? UIColor.clear : ColorConstants.lightGrayColor.color
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: color]
        let attributedPlaceholder = NSMutableAttributedString(string: placeholder,
                                                              attributes: attributes)
        
        self.attributedPlaceholder = attributedPlaceholder
    }
}
