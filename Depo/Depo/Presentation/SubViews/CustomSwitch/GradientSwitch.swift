//
//  GradientSwitch.swift
//  Depo
//
//  Created by Hooman Seven on 01/7/2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
class GradientSwitch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    //will set gradient color for switch On  state
    func configure() {
        onTintColor = .clear
        tintColor = ColorConstants.switcherGrayColor
        //         Switch height 32 pixel
        layer.cornerRadius = 16
        backgroundColor = ColorConstants.switcherGrayColor
        
        let onImage = Image.gradientSwitch.image
        self.onTintColor = UIColor(patternImage: onImage)
        
        self.clipsToBounds = true
    }
    
    
}
