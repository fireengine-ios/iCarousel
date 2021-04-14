//
//  BorderedWithInsetsTextField.swift
//  Depo
//
//  Created by Anton Ignatovich on 14.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedWithInsetsTextField: UITextField {

    private let fromRightTextThreshold: CGFloat = 4

    @IBInspectable
    var fromLeftTextInset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable
    var fromRightTextInset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    var cornerRadius: CGFloat = 4 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: fromLeftTextInset, bottom: 0, right: fromRightTextInset + fromRightTextThreshold))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: fromLeftTextInset, bottom: 0, right: fromRightTextInset + fromRightTextThreshold))
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - fromRightTextInset + fromRightTextThreshold, y: 0, width: fromRightTextInset, height: bounds.height)
    }
}
