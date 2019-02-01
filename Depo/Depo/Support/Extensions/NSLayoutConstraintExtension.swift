//
//  NSLayoutConstraintExtension.swift
//  Depo
//
//  Created by Raman Harhun on 1/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem, attribute: self.secondAttribute,
                                  multiplier: multiplier, constant: self.constant)
    }
}
