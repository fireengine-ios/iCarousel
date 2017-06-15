//
//  ButtonWithCorner.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ButtonWithCorner: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = ColorConstants.whiteColor.cgColor
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
    }

}
