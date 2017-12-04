//
//  InsetsTextField.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/1/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class InsetsTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 5 {
        didSet { layoutIfNeeded() }
    }
    @IBInspectable var insetY: CGFloat = 5 {
        didSet { layoutIfNeeded() }
    }
    
    /// placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    /// text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
