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

    override func layoutSubviews() {
        super.layoutSubviews()

        setCornerRadius()
    }
    
    func configurate() {
        backgroundColor = ColorConstants.whiteColor
        setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        layer.masksToBounds = true

        setCornerRadius()
        adjustsFontSizeToFitWidth()
    }
    
    func setCornerRadius() {
        guard bounds.height > 0 else {
            return
        }
        layer.cornerRadius = bounds.height * 0.5
        
        setInsets()
    }

    func setInsets() {
        let inset = frame.height * 0.3
        let isAddedImaged = image(for: .normal) != nil
        let leftInset: CGFloat = isAddedImaged ? 0.0 : inset
        insets = UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: inset)
    }
}
