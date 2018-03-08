//
//  CustomSwitch.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/24/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
class CustomSwitch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    func configure() {
        onTintColor = ColorConstants.switcherGreenColor
        tintColor = ColorConstants.switcherGrayColor
        // Switch height 32 pixel
        layer.cornerRadius = 16
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        backgroundColor = ColorConstants.switcherGrayColor
    }
}
