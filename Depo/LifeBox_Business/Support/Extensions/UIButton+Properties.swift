//
//  UIButton+Properties.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIButton {
    @IBInspectable var exclusiveTap: Bool {
        get { return isExclusiveTouch }
        set { isExclusiveTouch = newValue }
    }
}
