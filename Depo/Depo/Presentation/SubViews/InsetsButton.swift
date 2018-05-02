//
//  InsetsButton.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit.UIButton

class InsetsButton: UIButton {
    
    var insets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var topBottom: CGSize = .zero {
        didSet {
            insets.bottom = topBottom.width
            insets.top = topBottom.height
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var leftRight: CGSize = .zero {
        didSet {
            insets.left = leftRight.width
            insets.right = leftRight.height
            setNeedsDisplay()
        }
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return super.titleRect(forContentRect: UIEdgeInsetsInsetRect(contentRect, insets))
    }
    
    /// can be used
    //override func draw(_ rect: CGRect) {
    //    super.draw(UIEdgeInsetsInsetRect(rect, insets))
    //}
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size != .zero {
            size.width += insets.left + insets.right
            size.height += insets.top + insets.bottom
        }
        return size
    }
}
