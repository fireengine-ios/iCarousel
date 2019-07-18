//
//  BlueButtonWithWhiteText.swift
//  Depo
//
//  Created by Oleg on 06.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class BlueButtonWithMediumWhiteText: BlueButtonWithWhiteText {
    override func configurate() {
        super.configurate()

        titleLabel?.font = ApplicationPalette.mediumRoundButtonFont
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
    }
}

class BlueButtonWithWhiteText: WhiteButtonWithRoundedCorner {
    override func configurate() {
        super.configurate()
        
        setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
        setBackgroundColor(ColorConstants.darkBlueColor.lighter(by: 30.0), for: .disabled)
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        setTitleColor(ColorConstants.lightGrayColor, for: .disabled)
    }
}

final class BlueButtonWithNoFilesWhiteText: BlueButtonWithWhiteText {
    override func configurate() {
        super.configurate()

        titleLabel?.font = ApplicationPalette.noFilesRoundButtonFont
        titleLabel?.numberOfLines = 1
        titleLabel?.textAlignment = .center
    }
}
