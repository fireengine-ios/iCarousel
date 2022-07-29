//
//  UnderlineTextField.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {
    
    var underlineWidth: CGFloat = 1 {
        didSet { setNeedsDisplay() }
    }
    
    var underlineColor = AppColor.primaryBackground.color {
        didSet {
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        underlineLayer.backgroundColor = AppColor.primaryBackground.cgColor
        underlineLayer.borderColor = AppColor.borderColor.cgColor
        underlineLayer.borderWidth = 1.0
        
    }
    
    private let underlineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(underlineLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }  
}

