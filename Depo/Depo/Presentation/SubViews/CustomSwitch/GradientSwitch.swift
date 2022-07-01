//
//  GradientSwitch.swift
//  Depo
//
//  Created by Hooman Seven on 30/6/2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
class GradientSwitch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    func configure() {
        onTintColor = AppColor.tint.color
        tintColor = ColorConstants.switcherGrayColor
        // Switch height 32 pixel
        layer.cornerRadius = 16
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        backgroundColor = ColorConstants.switcherGrayColor
    }
}
