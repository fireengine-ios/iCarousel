//
//  CALayer+Animation.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension CALayer {
    static func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void){
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}
