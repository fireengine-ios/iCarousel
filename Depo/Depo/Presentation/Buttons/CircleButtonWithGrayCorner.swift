//
//  CircleButtonWithGrayCorner.swift
//  Depo_LifeTech
//
//  Created by Oleg on 04.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CircleButtonWithGrayCorner: ButtonWithGrayCorner {

    override func layoutSubviews() {
        super.layoutSubviews()
        setCornerRadius()
    }
    
    func setCornerRadius() {
        layer.cornerRadius = frame.size.height * 0.5
    }
    
}
