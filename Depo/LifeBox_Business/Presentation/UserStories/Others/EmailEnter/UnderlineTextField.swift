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
    
    var underlineColor = UIColor.white {
        didSet {
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
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
        
        underlineLayer.frame = CGRect(x: 0.0,
                                      y: frame.size.height - underlineWidth,
                                      width: frame.width,
                                      height: underlineWidth);
    }  
}

