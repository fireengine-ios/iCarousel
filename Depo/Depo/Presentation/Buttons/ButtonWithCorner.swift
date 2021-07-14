//
//  ButtonWithCorner.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ButtonWithCorner: InsetsButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    func configurate() {
        layer.borderWidth = 1.0
        layer.borderColor = getColorForCorner().cgColor
        
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        setTitleColor(getColorForText(), for: .normal)
        titleLabel?.font = ApplicationPalette.roundedCornersButtonFont
        
        let inset: CGFloat = 5
        insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func getColorForText() -> UIColor {
        return ColorConstants.whiteColor
    }
    
    func getColorForCorner() -> UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
    }
}
