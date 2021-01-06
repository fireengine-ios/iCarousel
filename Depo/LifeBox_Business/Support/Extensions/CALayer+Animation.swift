//
//  CALayer+Animation.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension CALayer {
    static func performWithoutAnimation(actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        actions()
        CATransaction.commit()
    }
}
