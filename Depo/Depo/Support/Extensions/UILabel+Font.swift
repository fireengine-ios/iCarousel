//
//  UILabel+Font.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 5/31/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UILabel {
    func adjustsFontSizeToFitWidth() {
        minimumScaleFactor = 0.5
        adjustsFontSizeToFitWidth = true
    }
}
