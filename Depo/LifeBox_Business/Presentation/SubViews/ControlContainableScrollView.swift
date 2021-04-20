//
//  ControlContainableScrollView.swift
//  Depo
//
//  Created by Raman Harhun on 4/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class ControlContainableScrollView: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl
            && !(view is UITextInput)
            && !(view is UISlider)
            && !(view is UISwitch) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }

}
