//
//  CircleYellowButton.swift
//  Depo_LifeTech
//
//  Created by Oleg on 04.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CircleYellowButton: WhiteButtonWithRoundedCorner {
    
    override func configurate() {
        super.configurate()
        backgroundColor = ColorConstants.yellowButtonColor
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 13)
        setCornerRadius()
    }
    
}
