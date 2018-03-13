//
//  BlueButtonWithWhiteText.swift
//  Depo
//
//  Created by Oleg on 06.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BlueButtonWithWhiteText: WhiteButtonWithRoundedCorner {

    override func configurate() {
        setCornerRadius()
        setBackgroundColor(ColorConstants.darcBlueColor, for: .normal)
        setBackgroundColor(ColorConstants.darcBlueColor.lighter(by: 30.0), for: .disabled)
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        setTitleColor(ColorConstants.lightGrayColor, for: .disabled)
        titleLabel?.font = ApplicationPalette.bigRoundButtonFont
    }
}

final class BlueButtonWithMediumWhiteText: BlueButtonWithWhiteText {
    
    override func configurate() {
        super.configurate()
        titleLabel?.font = ApplicationPalette.mediumRoundButtonFont
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
    
    override func setCornerRadius() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            layer.cornerRadius = frame.size.height * 0.4
        } else {
            layer.cornerRadius = frame.size.height * 0.5
        }
    }
}

final class BlueButtonWithNoFilesWhiteText: BlueButtonWithWhiteText {
    
    override func configurate() {
        super.configurate()
        titleLabel?.font = ApplicationPalette.noFilesRoundButtonFont
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
}
