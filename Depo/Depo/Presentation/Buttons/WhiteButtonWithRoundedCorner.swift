//
//  WhiteButtonWithRoundedCorner.swift
//  Depo
//
//  Created by Oleg on 20.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class WhiteButtonWithRoundedCorner: InsetsButton {

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
        
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byClipping
    }
    
    func setCornerRadius() {
        layer.cornerRadius = frame.height * 0.5
        
        let inset = frame.height * 0.3
        insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
