//
//  ButtonWithGrayCorner.swift
//  Depo
//
//  Created by Oleg on 07.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ButtonWithGrayCorner: ButtonWithCorner {

    override func getColorForText() -> UIColor {
        return ColorConstants.textGrayColor
    }
    
    override func getColorForCorner() -> UIColor {
        return ColorConstants.textGrayColor
    }

}
