//
//  BlueButtonWithWhiteText.swift
//  Depo
//
//  Created by Oleg on 06.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BlueButtonWithWhiteText: WhiteButtonWithRoundedCorner {

    override func configurate(){
        backgroundColor = ColorConstants.darcBlueColor
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        setTitleColor(ColorConstants.lightGrayColor, for: .disabled)
        titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        setCornerRadius()
    }
}
