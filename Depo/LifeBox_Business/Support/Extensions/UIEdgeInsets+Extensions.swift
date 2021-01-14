//
//  UIEdgeInsets+Extensions.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


extension UIEdgeInsets {
    init(topBottom: CGFloat, rightLeft: CGFloat) {
        self.init(top: topBottom, left: rightLeft, bottom: topBottom, right: rightLeft)
    }
}
