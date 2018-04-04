//
//  WhiteButtonWithRoundedCorner.swift
//  Depo
//
//  Created by Oleg on 20.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class WhiteButtonWithRoundedCorner: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setCornerRadius()
    }
    
    func configurate() {
        backgroundColor = ColorConstants.whiteColor
        setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        layer.masksToBounds = true
        setCornerRadius()
    }
    
    func setCornerRadius() {
        layer.cornerRadius = frame.size.height * 0.5
    }
    
}
